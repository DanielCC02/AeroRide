// lib/services/aircraft_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';

import '../models/aircraft_model.dart';
import '../models/available_aircraft_model.dart';
import '../models/search_criteria.dart';

class AircraftService {
  Future<Map<String, String>> _headers({bool jsonBody = true}) async {
    final token = await TokenStorage.getAccessToken();
    final hdrs = <String, String>{
      if (jsonBody) 'Content-Type': 'application/json',
      // aceptamos JSON y (por si acaso) text/plain porque Swagger lo muestra así
      'Accept': 'application/json, text/plain;q=0.9',
    };
    if (token != null && token.isNotEmpty) {
      hdrs['Authorization'] = 'Bearer $token';
    }
    return hdrs;
  }

  Uri _uri(String path, [Map<String, String>? q]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: q);
  }

  String _fold(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâãå]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöôõ]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  T _as<T>(dynamic v, T fallback) {
    if (v == null) return fallback;
    if (T == int) {
      return (v is num ? v.toInt() : int.tryParse('$v') ?? (fallback as int))
          as T;
    }
    if (T == double) {
      return (v is num
              ? v.toDouble()
              : double.tryParse('$v') ?? (fallback as double))
          as T;
    }
    if (T == String) return '$v' as T;
    if (T == bool) {
      if (v is bool) return v as T;
      final s = '$v'.toLowerCase();
      return (s == 'true' || s == '1' || s == 'yes') as T;
    }
    return fallback;
  }

  // =========================================================================
  // NUEVO: llamada preferida a GET /api/Aircrafts/grouped (GET con body JSON)
  // =========================================================================
  Future<List<AvailableAircraftModel>> _fetchGrouped(SearchCriteria c) async {
    final uri = _uri('/api/Aircrafts/grouped');
    final hdrs = await _headers(jsonBody: true);

    // body según swagger (companyId es opcional; lo omitimos para listar todo)
    final body = <String, dynamic>{
      'minSeats': c.passengers,
      'departureAirportId': c.from.id,
      'arrivalAirportId': c.to.id,
      'departureTime': c.departure.toUtc().toIso8601String(),
    };

    // GET con body ⇒ usar http.Request
    final req = http.Request('GET', uri)
      ..headers.addAll(hdrs)
      ..body = jsonEncode(body);

    final streamed = await http.Client().send(req);
    final text = await streamed.stream.bytesToString();

    // 204 → vacío
    if (streamed.statusCode == 204) return <AvailableAircraftModel>[];

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      final data = json.decode(text);
      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map((m) => AvailableAircraftModel.fromJson(m))
            .toList();
      }
    }

    throw HttpException(
      'GET /api/Aircrafts/grouped -> ${streamed.statusCode}: $text',
    );
  }

  // =========================
  // Modelos disponibles
  // =========================
  Future<List<AvailableAircraftModel>> listAvailableModelsFor(
    SearchCriteria criteria,
  ) async {
    // 1) Endpoint NUEVO del backend (preferido)
    try {
      final list = await _fetchGrouped(criteria);
      if (list.isNotEmpty) return list;
      // si viene vacío, igual devolvemos vacío (sin forzar fallback)
      return list;
    } catch (_) {
      // seguimos al fallback si falla
    }

    // 2) Fallback legacy: /api/aircrafts/available-models (si existe)
    try {
      final hdrs = await _headers();
      final url = _uri('/api/aircrafts/available-models', {
        'fromAirportId': '${criteria.from.id}',
        'toAirportId': '${criteria.to.id}',
        'departureTimeUtc': criteria.departure.toUtc().toIso8601String(),
        'passengers': '${criteria.passengers}',
      });
      final r = await http.get(url, headers: hdrs);
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final data = json.decode(r.body);
        if (data is List) {
          return data
              .cast<Map<String, dynamic>>()
              .map((m) => AvailableAircraftModel.fromJson(m))
              .toList();
        }
      }
    } catch (_) {}

    // 3) Fallback final: GET /api/aircrafts + filtro FE (lo que ya tenías)
    try {
      final hdrs = await _headers();
      final r = await http.get(_uri('/api/aircrafts'), headers: hdrs);
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final rawList = (json.decode(r.body) as List)
            .cast<Map<String, dynamic>>();

        final nameIdCache = <String, int>{};
        final filtered = <Map<String, dynamic>>[];

        for (final raw in rawList) {
          final seats = _as<int>(raw['seats'] ?? raw['Seats'], 0);
          final isActive = _as<bool>(raw['isActive'] ?? raw['IsActive'], true);
          if (!isActive) continue;
          if (seats < criteria.passengers) continue;

          var companyId = _as<int>(raw['companyId'] ?? raw['CompanyId'], 0);
          final companyName = _as<String>(
            raw['companyName'] ?? raw['CompanyName'],
            '',
          );
          if (companyId == 0 && companyName.isNotEmpty) {
            final key = companyName.toLowerCase().trim();
            if (nameIdCache.containsKey(key)) {
              companyId = nameIdCache[key]!;
            } else {
              final resolved = await getCompanyIdByName(companyName) ?? 0;
              nameIdCache[key] = resolved;
              companyId = resolved;
            }
          }

          final model = _as<String>(raw['model'] ?? raw['Model'], '');
          final image = _as<String>(raw['image'] ?? raw['Image'], '');
          final baseCountry = _as<String>(
            raw['baseCountry'] ?? raw['BaseCountry'] ?? '',
            '',
          );

          filtered.add({
            'companyId': companyId,
            'companyName': companyName,
            'model': model, // ← exacto como viene
            'seats': seats,
            'image': image,
            'baseCountry': baseCountry,
          });
        }

        // Dedupe por (companyId | modelo EXACTO sin transformar)
        final map = <String, AvailableAircraftModel>{};
        for (final a in filtered) {
          final key =
              '${a['companyId']}|${(a['model'] ?? '').toString().trim()}';
          map.putIfAbsent(
            key,
            () => AvailableAircraftModel(
              companyId: _as<int>(a['companyId'], 0),
              companyName: _as<String>(a['companyName'], ''),
              model: _as<String>(a['model'], ''),
              image: _as<String>(a['image'], ''),
              seats: _as<int>(a['seats'], 0),
              estimatedPrice: null,
              baseCountry: _as<String>(a['baseCountry'], ''),
            ),
          );
        }
        return map.values.toList();
      }
    } catch (_) {}

    return <AvailableAircraftModel>[];
  }

  // =========================
  // LOOKUP de compañías
  // =========================
  Future<int?> getCompanyIdByName(String name) async {
    final q = name.trim();
    if (q.isEmpty) return null;

    final hdrs = await _headers();
    final candidates = <Map<String, dynamic>>[];
    final urls = <Uri>[
      _uri('/api/companies', {'search': q}),
      _uri('/api/companies'),
      _uri('/api/companies/all'),
      _uri('/api/company'),
      _uri('/api/company/all'),
      _uri('/api/companies/active'),
      _uri('/api/companies/list'),
    ];

    for (final url in urls) {
      try {
        final r = await http.get(url, headers: hdrs);
        if (r.statusCode >= 200 && r.statusCode < 300) {
          final data = json.decode(r.body);
          if (data is List) {
            candidates.addAll(data.cast<Map<String, dynamic>>());
            if (candidates.isNotEmpty) break;
          }
        }
      } catch (_) {}
    }

    if (candidates.isEmpty) return null;

    String norm(String s) => _fold(s);
    final fq = norm(q);

    candidates.sort((a, b) {
      final an = norm((a['name'] ?? a['Name'] ?? '').toString());
      final bn = norm((b['name'] ?? b['Name'] ?? '').toString());
      int score(String n) {
        int s = 0;
        if (n == fq) s += 1000;
        if (n.startsWith(fq)) s += 600;
        if (n.contains(fq)) s += 300;
        return s;
      }

      return score(bn).compareTo(score(an));
    });

    final best = candidates.first;
    final id = (best['id'] is num)
        ? (best['id'] as num).toInt()
        : (best['Id'] is num)
        ? (best['Id'] as num).toInt()
        : null;
    return id;
  }

  // =========================
  // LOOKUPs de aeronaves (sin cambios funcionales)
  // =========================
  Future<AircraftModel?> findFirstAircraftByCompanyAndModel({
    required int companyId,
    required String model,
  }) async {
    final hdrs = await _headers();
    final cand = model.trim().toLowerCase();
    for (final url in <Uri>[
      _uri('/api/aircrafts', {'companyId': '$companyId'}),
      _uri('/api/aircrafts'),
    ]) {
      try {
        final r = await http.get(url, headers: hdrs);
        if (r.statusCode >= 200 && r.statusCode < 300) {
          final all = (json.decode(r.body) as List)
              .cast<Map<String, dynamic>>()
              .map((m) => AircraftModel.fromJson(m))
              .toList();

          var list = all
              .where((a) => a.isActive && (a.companyId ?? 0) == companyId)
              .toList();
          if (list.isEmpty) list = all.where((a) => a.isActive).toList();

          final exact = list.where((a) => a.model == model);
          if (exact.isNotEmpty) return exact.first;

          final exactCi = list.where((a) => a.model.toLowerCase() == cand);
          if (exactCi.isNotEmpty) return exactCi.first;

          final starts = list.where(
            (a) => a.model.toLowerCase().startsWith(cand),
          );
          if (starts.isNotEmpty) return starts.first;

          final contains = list.where(
            (a) => a.model.toLowerCase().contains(cand),
          );
          if (contains.isNotEmpty) return contains.first;
        }
      } catch (_) {}
    }
    return null;
  }

  Future<String?> findCanonicalModelForCompany({
    required int companyId,
    required String candidateModel,
  }) async {
    final hdrs = await _headers();
    final cand = _fold(candidateModel);
    for (final url in <Uri>[
      _uri('/api/aircrafts', {'companyId': '$companyId'}),
      _uri('/api/aircrafts'),
    ]) {
      try {
        final r = await http.get(url, headers: hdrs);
        if (r.statusCode >= 200 && r.statusCode < 300) {
          final all = (json.decode(r.body) as List)
              .cast<Map<String, dynamic>>()
              .map((m) => AircraftModel.fromJson(m))
              .toList();

          var list = all
              .where((a) => a.isActive && (a.companyId ?? 0) == companyId)
              .toList();
          if (list.isEmpty) list = all.where((a) => a.isActive).toList();
          if (list.isEmpty) return null;

          final models = list.map((a) => a.model).toSet().toList();
          String? best;
          int bestScore = -1;
          for (final m in models) {
            final f = _fold(m);
            int s = 0;
            if (f == cand) s += 1000;
            if (f.startsWith(cand)) s += 600;
            if (f.contains(cand)) s += 300;
            if (cand.contains(f)) s += 100;
            if (s > bestScore) {
              bestScore = s;
              best = m;
            }
          }
          if (bestScore > 0) return best;
        }
      } catch (_) {}
    }
    return null;
  }

  // =========================
  // Métodos compat (sin cambios)
  // =========================
  Future<AircraftModel?> getAircraftById(int id) async {
    final hdrs = await _headers();
    try {
      final r = await http.get(_uri('/api/aircrafts/$id'), headers: hdrs);
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return AircraftModel.fromJson(
          json.decode(r.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    try {
      final r = await http.get(_uri('/api/aircrafts'), headers: hdrs);
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final list = (json.decode(r.body) as List)
            .cast<Map<String, dynamic>>()
            .map((m) => AircraftModel.fromJson(m))
            .toList();
        final match = list.where((a) => a.id == id);
        return match.isNotEmpty ? match.first : null;
      }
    } catch (_) {}
    return null;
  }

// MÉTODOS DE TOMÁS

  Future<List<AircraftModel>> getAircraftsByCompany(int companyId) async {
    final hdrs = await _headers();

    try {
      final r = await http.get(
        _uri('/api/aircrafts/company/$companyId/all'),
        headers: hdrs,
      );

      if (r.statusCode >= 200 && r.statusCode < 300) {
        return (json.decode(r.body) as List)
            .cast<Map<String, dynamic>>()
            .map((m) => AircraftModel.fromJson(m))
            .toList();
      }

      if (r.statusCode == 204) {
        return [];
      }
    } catch (_) {}

    return <AircraftModel>[];
  }

  Future<AircraftModel> createAircraft({
    required int companyId,
    required int baseAirportId,
    String? patent,
    required String model,
    required double minuteCost,
    required int seats,
    required int emptyWeight,
    required int maxWeight,
    required double cruisingSpeed,
    required bool canFlyInternational,
    String state = 'Disponible',
    bool isActive = true,
    int? currentAirportId,
    String? image,
  }) async {
    final hdrs = await _headers();
    final body = json.encode({
      'companyId': companyId,
      'baseAirportId': baseAirportId,
      if (currentAirportId != null) 'currentAirportId': currentAirportId,
      'patent': patent ?? '',
      'model': model,
      'minuteCost': minuteCost,
      'seats': seats,
      'emptyWeight': emptyWeight,
      'maxWeight': maxWeight,
      'cruisingSpeed': cruisingSpeed,
      'canFlyInternational': canFlyInternational,
      'state': state,
      'image': image ?? '',
      'isActive': isActive,
    });

    final r = await http.post(
      _uri('/api/aircrafts'),
      headers: hdrs,
      body: body,
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return AircraftModel.fromJson(
        json.decode(r.body) as Map<String, dynamic>,
      );
    }
    throw HttpException(
      'Failed to create aircraft (${r.statusCode}): ${r.body}',
    );
  }

  Future<AircraftModel> updateAircraft(
    int id, {
    int? companyId,
    int? baseAirportId,
    int? currentAirportId,
    String? patent,
    String? model,
    double? minuteCost,
    int? seats,
    int? emptyWeight,
    int? maxWeight,
    double? cruisingSpeed,
    bool? canFlyInternational,
    String? state,
    String? image,
    bool? isActive,
  }) async {
    final hdrs = await _headers();

    final payload = <String, dynamic>{
      if (companyId != null) 'companyId': companyId,
      if (baseAirportId != null) 'baseAirportId': baseAirportId,
      if (currentAirportId != null) 'currentAirportId': currentAirportId,
      if (patent != null) 'patent': patent,
      if (model != null) 'model': model,
      if (minuteCost != null) 'minuteCost': minuteCost,
      if (seats != null) 'seats': seats,
      if (emptyWeight != null) 'emptyWeight': emptyWeight,
      if (maxWeight != null) 'maxWeight': maxWeight,
      if (cruisingSpeed != null) 'cruisingSpeed': cruisingSpeed,
      if (canFlyInternational != null)
        'canFlyInternational': canFlyInternational,
      if (state != null) 'state': state,
      if (image != null) 'image': image,
      if (isActive != null) 'isActive': isActive,
    };

    final r = await http.put(
      _uri('/api/aircrafts/$id'),
      headers: hdrs,
      body: json.encode(payload),
    );

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return AircraftModel.fromJson(json.decode(r.body));
    }

    throw HttpException(
      'Failed to update aircraft (${r.statusCode}): ${r.body}',
    );
  }

  Future<void> deactivateAircraft(int id) async {
    final hdrs = await _headers();

    final r = await http.delete(_uri('/api/aircrafts/$id'), headers: hdrs);

    if (r.statusCode >= 200 && r.statusCode < 300) return;

    throw HttpException(
      'Failed to deactivate aircraft $id (${r.statusCode}): ${r.body}',
    );
  }

  Future<void> reactivateAircraft(int id) async {
    final hdrs = await _headers();

    final r = await http.put(
      _uri('/api/aircrafts/reactivate/$id'),
      headers: hdrs,
    );

    if (r.statusCode >= 200 && r.statusCode < 300) return;

    throw HttpException(
      'Failed to reactivate aircraft $id (${r.statusCode}): ${r.body}',
    );
  }

  Future<String> uploadImageFile(File file) async {
    final token = await TokenStorage.getAccessToken();
    final headers = {if (token != null) 'Authorization': 'Bearer $token'};

    final url = _uri('/api/aircrafts/upload-image');
    final req = http.MultipartRequest('POST', url);
    req.headers.addAll(headers);
    req.files.add(await http.MultipartFile.fromPath('file', file.path));

    final resp = await http.Response.fromStream(await req.send());

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final jsonMap = json.decode(resp.body);
      return jsonMap['imageUrl']; // ✔ tu backend usa imageUrl
    }

    throw HttpException('Failed to upload aircraft image (${resp.statusCode})');
  }

  Future<String> uploadAircraftImage(int id, String filePath) async {
    final token = await TokenStorage.getAccessToken();
    final headers = {if (token != null) 'Authorization': 'Bearer $token'};

    final url = _uri('/api/aircrafts/upload-image');
    final req = http.MultipartRequest('POST', url);
    req.headers.addAll(headers);
    req.files.add(await http.MultipartFile.fromPath('file', filePath));

    final resp = await http.Response.fromStream(await req.send());

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final jsonMap = json.decode(resp.body);
      return jsonMap['imageUrl'];
    }

    throw HttpException('Failed to upload aircraft image (${resp.statusCode})');
  }

  /*Future<AircraftModel> updateAircraft(
    int id, {
    int? companyId,
    int? baseAirportId,
    int? currentAirportId,
    String? patent,
    String? model,
    double? minuteCost,
    int? seats,
    int? emptyWeight,
    int? maxWeight,
    double? cruisingSpeed,
    bool? canFlyInternational,
    String? state,
    String? image,
    bool? isActive,
  }) async {
    final hdrs = await _headers();
    final payload = <String, dynamic>{
      if (companyId != null) 'companyId': companyId,
      if (baseAirportId != null) 'baseAirportId': baseAirportId,
      if (currentAirportId != null) 'currentAirportId': currentAirportId,
      if (patent != null) 'patent': patent,
      if (model != null) 'model': model,
      if (minuteCost != null) 'minuteCost': minuteCost,
      if (seats != null) 'seats': seats,
      if (emptyWeight != null) 'emptyWeight': emptyWeight,
      if (maxWeight != null) 'maxWeight': maxWeight,
      if (cruisingSpeed != null) 'cruisingSpeed': cruisingSpeed,
      if (canFlyInternational != null)
        'canFlyInternational': canFlyInternational,
      if (state != null) 'state': state,
      if (image != null) 'image': image,
      if (isActive != null) 'isActive': isActive,
    };
    final body = json.encode(payload);

    var r = await http.patch(
      _uri('/api/aircrafts/$id'),
      headers: hdrs,
      body: body,
    );
    if (r.statusCode == 404) {
      r = await http.put(_uri('/api/aircrafts/$id'), headers: hdrs, body: body);
    }
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return AircraftModel.fromJson(
        json.decode(r.body) as Map<String, dynamic>,
      );
    }
    throw HttpException(
      'Failed to update aircraft (${r.statusCode}): ${r.body}',
    );
  } 

  Future<void> deactivateAircraft(int id) async {
    final hdrs = await _headers();
    final endpoints = <Future<http.Response>>[
      http.patch(_uri('/api/aircrafts/$id/deactivate'), headers: hdrs),
      http.patch(
        _uri('/api/aircrafts/$id'),
        headers: hdrs,
        body: json.encode({'isActive': false}),
      ),
      http.put(_uri('/api/aircrafts/$id/deactivate'), headers: hdrs),
      http.post(_uri('/api/aircrafts/$id/deactivate'), headers: hdrs),
    ];
    for (final call in endpoints) {
      try {
        final r = await call;
        if (r.statusCode >= 200 && r.statusCode < 300) return;
      } catch (_) {}
    }
    throw HttpException(
      'Failed to deactivate aircraft $id (no route matched).',
    );
  }

  Future<void> reactivateAircraft(int id) async {
    final hdrs = await _headers();
    final endpoints = <Future<http.Response>>[
      http.patch(_uri('/api/aircrafts/$id/reactivate'), headers: hdrs),
      http.patch(
        _uri('/api/aircrafts/$id'),
        headers: hdrs,
        body: json.encode({'isActive': true}),
      ),
      http.put(_uri('/api/aircrafts/$id/reactivate'), headers: hdrs),
      http.post(_uri('/api/aircrafts/$id/reactivate'), headers: hdrs),
    ];
    for (final call in endpoints) {
      try {
        final r = await call;
        if (r.statusCode >= 200 && r.statusCode < 300) return;
      } catch (_) {}
    }
    throw HttpException(
      'Failed to reactivate aircraft $id (no route matched).',
    );
  } 

  Future<String> uploadAircraftImage(int id, String filePath) async {
    final token = await TokenStorage.getAccessToken();
    final Map<String, String> authHeader = {};
    if (token != null && token.isNotEmpty) {
      authHeader['Authorization'] = 'Bearer $token';
    }

    try {
      final url = _uri('/api/aircrafts/$id/image');
      final req = http.MultipartRequest('POST', url);
      req.headers.addAll(authHeader);
      req.files.add(await http.MultipartFile.fromPath('file', filePath));
      final resp = await http.Response.fromStream(await req.send());
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final jsonMap = json.decode(resp.body);
        if (jsonMap is Map && jsonMap['url'] != null) {
          return jsonMap['url'].toString();
        }
        if (jsonMap is Map && jsonMap['image'] != null) {
          return jsonMap['image'].toString();
        }
      }
    } catch (_) {}

    try {
      final url = _uri('/api/files/aircrafts');
      final req = http.MultipartRequest('POST', url);
      req.headers.addAll(authHeader);
      req.fields['aircraftId'] = '$id';
      req.files.add(await http.MultipartFile.fromPath('file', filePath));
      final resp = await http.Response.fromStream(await req.send());
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final jsonMap = json.decode(resp.body);
        if (jsonMap is Map && jsonMap['url'] != null) {
          return jsonMap['url'].toString();
        }
        if (jsonMap is Map && jsonMap['image'] != null) {
          return jsonMap['image'].toString();
        }
      }
    } catch (_) {}

    throw HttpException('Failed to upload image for aircraft $id.');
  }

  Future<String> uploadImageFile(File file) async {
    final token = await TokenStorage.getAccessToken();
    final Map<String, String> authHeader = {};
    if (token != null && token.isNotEmpty) {
      authHeader['Authorization'] = 'Bearer $token';
    }

    final url = _uri('/api/files/aircrafts');
    final req = http.MultipartRequest('POST', url);
    req.headers.addAll(authHeader);
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    final resp = await http.Response.fromStream(await req.send());
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final jsonMap = json.decode(resp.body);
      if (jsonMap is Map && jsonMap['url'] != null) {
        return jsonMap['url'].toString();
      }
      if (jsonMap is Map && jsonMap['image'] != null) {
        return jsonMap['image'].toString();
      }
    }
    throw HttpException('Failed to upload image (pre-ID).');
  } */
}
