// lib/services/airport_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';
import '../models/airport_model.dart';

class AirportService {
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
    // Pedimos más resultados al backend para poder filtrar bien en cliente
    const fetchSize = 100;

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

    if (q.isEmpty) {
      return all.take(limit).toList();
    }

    // Filtro y ranking local (accent-insensitive)
    final ranked = _rankAndFilter(all, q);
    return ranked.take(limit).toList();
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
}
