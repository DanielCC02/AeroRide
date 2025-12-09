// lib/services/airport_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';
import '../models/airport_model.dart';

import 'cache/simple_cache.dart';

class AirportService {
  static final SimpleCache<String, List<Airport>> _searchCache = SimpleCache(
    ttl: const Duration(minutes: 5),
    maxEntries: 300,
  );

  // --------------------
  // Infra
  // --------------------
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getAccessToken();
    final hdrs = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      hdrs['Authorization'] = 'Bearer $token';
    }
    return hdrs;
  }

  static Uri _uri(String path, [Map<String, String>? q]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: q);
  }

  static Future<http.Response> _getFirstOk(List<Uri> tries) async {
    final headers = await _headers();
    http.Response? last;
    for (final u in tries) {
      try {
        final r = await http.get(u, headers: headers);
        if (r.statusCode >= 200 && r.statusCode < 300) return r;
        last = r;
        if (r.statusCode == 404 || r.statusCode == 405) continue;
      } catch (_) {
        // intenta siguiente variante
      }
    }
    return last ?? http.Response('No endpoint responded', 500);
  }

  // --------------------
  // Helpers PRIVADOS añadidos (no rompen nada existente)
  // --------------------

  // ¿A este aeropuerto le "faltan" horarios o zona horaria?
  static bool _needsHydration(Airport a) {
    final missingTimes =
        (a.openingTime == null || a.openingTime!.isEmpty) ||
        (a.closingTime == null || a.closingTime!.isEmpty);
    final missingTz = a.timeZone.isEmpty || a.timeZone.toUpperCase() == 'UTC';
    return missingTimes || missingTz;
  }

  // GET /api/airports/{id} estático (evita tocar tu método público existente)
  static Future<Airport?> _fetchAirportByIdStatic(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/airports/$id');
    final headers = await _headers();
    try {
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode >= 200 &&
          resp.statusCode < 300 &&
          resp.body.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(resp.body);
        return Airport.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  // Hidrata (completa) horarios/TimeZone de los primeros N si faltan.
  static Future<void> _hydrateTopIfNeeded(
    List<Airport> list, {
    int max = 8,
  }) async {
    int done = 0;
    final futures = <Future<void>>[];
    for (var i = 0; i < list.length && done < max; i++) {
      final a = list[i];
      if (_needsHydration(a)) {
        done++;
        futures.add(() async {
          final full = await _fetchAirportByIdStatic(a.id);
          if (full != null) {
            list[i] = full; // reemplaza con el completo
          }
        }());
      }
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  // --------------------
  // Search mejorado (accent-insensitive + por nombre/ciudad)
  // --------------------
  /// Busca aeropuertos. Si el backend no filtra por nombre/ciudad,
  /// aplicamos un filtro local "accent-insensitive" y los ordenamos por relevancia.
  ///
  /// Relevancia:
  /// 1) name/city que **empieza** con el query
  /// 2) name/city que **contiene** el query
  /// 3) IATA/OACI que coincide/contiene
  /// (todo sin acentos y case-insensitive)
  static Future<List<Airport>> searchAirports(
    String query, {
    int limit = 2,
  }) async {
    final q = query.trim();

    const int fetchSize =
        100; // cantidad a pedir al backend para filtrar en cliente

    if (q.isEmpty) return <Airport>[];

    // ⬇️ Intentar caché
    final ck = 'q=$q|limit=$limit';
    final cached = _searchCache.get(ck);
    if (cached != null) {
      return cached.take(limit).toList();
    }

    final tries = <Uri>[];
    if (q.isNotEmpty) {
      tries.add(
        _uri('/api/airports/search', {'query': q, 'limit': '$fetchSize'}),
      );
      tries.add(_uri('/api/airports', {'search': q}));
      tries.add(_uri('/api/airports')); // listado general (fallback)
    } else {
      tries.add(
        _uri('/api/airports/search', {'query': '', 'limit': '$fetchSize'}),
      );
      tries.add(_uri('/api/airports'));
    }

    final resp = await _getFirstOk(tries);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      return <Airport>[];
    }

    final body = resp.body.isEmpty ? '[]' : resp.body;
    final decoded = json.decode(body);

    List items;
    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map && decoded['items'] is List) {
      items = decoded['items'] as List;
    } else {
      items = [];
    }

    final all = items
        .map((e) => Airport.fromJson(e as Map<String, dynamic>))
        .toList();

    // NUEVO: reforzar datos de los primeros N si faltan horarios/tz.
    // Lo hacemos ANTES del ranking para que, al seleccionar, ya vengan completos.
    await _hydrateTopIfNeeded(all, max: limit * 2);

    if (q.isEmpty) {
      return all.take(limit).toList();
    }

    final ranked = _rankAndFilter(all, q);
    final out = ranked.take(limit).toList();

    // ⬇Guardar en caché una versión extendida (hasta 20) para que sucesivas
    // búsquedas con el mismo prefijo sean más rápidas.
    _searchCache.set(ck, ranked.take(20).toList());
    return out;
  }

  // --------------------
  // Helpers de ranking
  // --------------------
  static List<Airport> _rankAndFilter(List<Airport> src, String query) {
    final q = _fold(query);

    int score(Airport a) {
      final name = _fold(a.name);
      final city = _fold(a.city);
      final country = _fold(a.country);
      final iata = _fold(a.codeIATA);
      final oaci = _fold(a.codeOACI);

      int s = 0;

      // Comienza con...
      if (name.startsWith(q)) s += 1000;
      if (city.startsWith(q)) s += 800;

      // Contiene...
      if (name.contains(q)) s += 400;
      if (city.contains(q)) s += 300;
      if (country.contains(q)) s += 120;

      // IATA / OACI
      if (iata == q) s += 700;
      if (oaci == q) s += 650;
      if (iata.contains(q)) s += 250;
      if (oaci.contains(q)) s += 200;

      return s;
    }

    final filtered =
        src.where((a) {
          final f = _fold(
            '${a.name} ${a.city} ${a.country} ${a.codeIATA} ${a.codeOACI}',
          );
          return f.contains(q) ||
              _fold(a.name).startsWith(q) ||
              _fold(a.city).startsWith(q);
        }).toList()..sort((a, b) {
          final sb = score(b);
          final sa = score(a);
          if (sb != sa) return sb.compareTo(sa);
          // desempate alfabético por nombre
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

    return filtered;
  }

  /// Quita acentos/diacríticos y pasa a minúsculas para comparar.
  static String _fold(String s) {
    final lower = s.toLowerCase();
    return lower
        // Vocales con acento / diéresis
        .replaceAll(RegExp(r'[áàäâãå]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        // eñes
        .replaceAll(RegExp(r'[ñ]'), 'n')
        // quitar caracteres no alfanuméricos (conserva espacios para "contiene")
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ======================================================
  // GET: /api/airports/all
  // ======================================================
  /// Obtiene todos los aeropuertos (activos e inactivos) del sistema.
  /// Solo accesible por administradores o CompanyAdmin.
  Future<List<Airport>> getAllAirports() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/airports/all');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Mapea cada elemento JSON al modelo Airport
      return data
          .map((e) => Airport.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      debugPrint('⚠️ Error al obtener aeropuertos: ${response.statusCode}');
      throw Exception('Error al obtener la lista de aeropuertos');
    }
  }

  // ======================================================
  // GET: /api/airports  → Solo aeropuertos activos
  // ======================================================
  /// Obtiene únicamente los aeropuertos activos (ordenados por Id ascendente).
  /// Endpoint: GET /api/airports
  /// Roles permitidos: Admin, CompanyAdmin, Pilot, User
  Future<List<Airport>> getActiveAirports() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/airports');
    debugPrint('GET $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Airport.fromJson(e)).toList();
    } else {
      debugPrint('❌ Error al obtener aeropuertos activos: ${response.body}');
      throw Exception('Error al obtener la lista de aeropuertos activos');
    }
  }

  // ======================================================
  // GET: Obtener aeropuerto por ID
  // ======================================================
  Future<Airport> getAirportById(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/airports/$id');

    debugPrint('GET $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Airport.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Aeropuerto no encontrado');
    } else {
      debugPrint('❌ Error al obtener aeropuerto: ${response.body}');
      throw Exception(
        'Error al obtener aeropuerto (status: ${response.statusCode})',
      );
    }
  }

  // ======================================================
  // POST: Crear un nuevo aeropuerto
  // ======================================================
  Future<void> createAirport({
    required String name,
    required String codeIATA,
    required String codeOACI,
    required String city,
    required String country,
    required String timeZone,
    required double latitude,
    required double longitude,
    required String imageUrl,
    int? maxAllowedWeight,
    String? openingTime, // "HH:mm:ss"
    String? closingTime, // "HH:mm:ss"
    int departureMarginMinutes = 60,
    int arrivalMarginMinutes = 30,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/airports');

    final body = {
      'name': name,
      'codeIATA': codeIATA,
      'codeOACI': codeOACI,
      'city': city,
      'country': country,
      'timeZone': timeZone,
      'latitude': latitude,
      'longitude': longitude,
      'image': imageUrl,

      if (maxAllowedWeight != null) 'maxAllowedWeight': maxAllowedWeight,
      if (openingTime != null && openingTime.isNotEmpty)
        'openingTime': openingTime,
      if (closingTime != null && closingTime.isNotEmpty)
        'closingTime': closingTime,
      'departureMarginMinutes': departureMarginMinutes,
      'arrivalMarginMinutes': arrivalMarginMinutes,
    };

    debugPrint('POST $url');
    debugPrint('Body enviado: $body');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Response: ${response.body}');

    if (response.statusCode == 201) {
      debugPrint('✅ Aeropuerto creado correctamente');
    } else {
      debugPrint('❌ Error al crear aeropuerto: ${response.body}');
      throw Exception('Error al crear aeropuerto');
    }
  }

  // ======================================================
  // POST: Subir imagen de aeropuerto
  // ======================================================
  Future<String> uploadAirportImage(File imageFile) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/airports/ImageUpload');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('Subiendo imagen: ${imageFile.path}');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl']; // URL pública del blob en Azure
    } else {
      debugPrint('❌ Error al subir imagen: ${response.body}');
      throw Exception('Error al subir imagen de aeropuerto');
    }
  }

  // ===========================================================
  // PUT: Actualizar aeropuerto
  // ===========================================================
  Future<void> updateAirport({
    required int id,
    required String name,
    required String codeIATA,
    required String codeOACI,
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required String timeZone,
    String? openingTime, // formato HH:mm:ss opcional
    String? closingTime, // formato HH:mm:ss opcional
    int? maxAllowedWeight,
    String? imageUrl,
    int? departureMarginMinutes,
    int? arrivalMarginMinutes,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/airports/$id');

    final body = {
      'name': name,
      'codeIATA': codeIATA,
      'codeOACI': codeOACI,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'timeZone': timeZone,

      if (openingTime != null && openingTime.isNotEmpty)
        'openingTime': openingTime,
      if (closingTime != null && closingTime.isNotEmpty)
        'closingTime': closingTime,
      if (maxAllowedWeight != null && maxAllowedWeight > 0)
        'maxAllowedWeight': maxAllowedWeight,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
      if (departureMarginMinutes != null)
        'departureMarginMinutes': departureMarginMinutes,
      if (arrivalMarginMinutes != null)
        'arrivalMarginMinutes': arrivalMarginMinutes,
    };

    debugPrint('PUT $url');
    debugPrint('Body enviado: $body');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Response: ${response.body}');

    if (response.statusCode == 200) {
      debugPrint('✅ Aeropuerto actualizado correctamente');
    } else if (response.statusCode == 404) {
      throw Exception('Aeropuerto no encontrado');
    } else if (response.statusCode == 400) {
      throw Exception('Datos inválidos: ${response.body}');
    } else {
      throw Exception(
        'Error al actualizar aeropuerto (status: ${response.statusCode})',
      );
    }
  }

  // ===========================================================
  // DELETE: Desactivar aeropuerto (soft delete)
  // ===========================================================
  Future<void> deactivateAirport(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/airports/$id');

    debugPrint('DELETE $url');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Aeropuerto desactivado correctamente');
    } else if (response.statusCode == 404) {
      throw Exception('Aeropuerto no encontrado');
    } else {
      debugPrint('❌ Error al desactivar aeropuerto: ${response.body}');
      throw Exception(
        'Error al desactivar aeropuerto (status: ${response.statusCode})',
      );
    }
  }

  // ===========================================================
  // PUT: Reactivar aeropuerto
  // ===========================================================
  Future<void> reactivateAirport(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/airports/reactivate/$id');

    debugPrint('PUT $url');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Aeropuerto reactivado correctamente');
    } else if (response.statusCode == 404) {
      throw Exception('Aeropuerto no encontrado');
    } else {
      debugPrint('❌ Error al reactivar aeropuerto: ${response.body}');
      throw Exception(
        'Error al reactivar aeropuerto (status: ${response.statusCode})',
      );
    }
  }
}
