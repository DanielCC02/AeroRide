import 'dart:convert';
import 'package:flutter/foundation.dart'; // 👈 para debugPrint
import 'package:http/http.dart' as http;

import '../models/empty_leg_summary_model.dart';
import '../models/empty_leg_detail_model.dart';
import 'api_config.dart';
import 'token_storage.dart';

class EmptyLegService {
  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: q);

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // =========================================================
  // GET /api/Flights/emptylegs
  // =========================================================
  Future<List<EmptyLegSummaryModel>> getEmptyLegs() async {
    final uri = _u('/api/Flights/emptylegs');
    final headers = await _headers();

    debugPrint('🟠 GET $uri');
    debugPrint('🟠 Headers: $headers');

    final r = await http.get(uri, headers: headers);

    debugPrint('🟢 getEmptyLegs status: ${r.statusCode}');
    debugPrint('🟢 getEmptyLegs body: "${r.body}"');

    // 204 No Content → simplemente no hay empty legs
    if (r.statusCode == 204 || r.body.trim().isEmpty) {
      return <EmptyLegSummaryModel>[];
    }

    if (r.statusCode >= 400) {
      throw Exception('Failed to load empty legs: ${r.statusCode} ${r.body}');
    }

    // Intentamos decodificar el JSON de forma defensiva
    final decoded = jsonDecode(r.body);

    if (decoded is List) {
      // Caso ideal: la API devuelve una lista directamente
      return decoded
          .map((e) => EmptyLegSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (decoded is Map<String, dynamic>) {
      // Por si la API devuelve un objeto con una lista adentro
      // Intentamos encontrar la primera propiedad que sea List
      List<dynamic>? listCandidate;

      // claves típicas
      final possibleKeys = ['items', 'data', 'result', 'emptyLegs', 'flights'];
      for (final k in possibleKeys) {
        final v = decoded[k];
        if (v is List) {
          listCandidate = v;
          break;
        }
      }

      // Si no encontramos con las claves típicas, buscamos la primera List
      listCandidate ??=
          decoded.values.firstWhere((v) => v is List, orElse: () => <dynamic>[])
              as List<dynamic>?;

      if (listCandidate == null) {
        throw Exception(
          'Unexpected empty legs payload. Map without list. Keys: ${decoded.keys}',
        );
      }

      return listCandidate
          .map((e) => EmptyLegSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Unexpected empty legs response type: ${decoded.runtimeType}',
      );
    }
  }

  // =========================================================
  // GET /api/Flights/emptylegs/{id}
  // =========================================================
  Future<EmptyLegDetailModel> getEmptyLegDetail(int id) async {
    final uri = _u('/api/Flights/emptylegs/$id');
    final headers = await _headers();

    debugPrint('🟠 GET $uri');
    final r = await http.get(uri, headers: headers);

    debugPrint('🟢 getEmptyLegDetail status: ${r.statusCode}');
    debugPrint('🟢 getEmptyLegDetail body: "${r.body}"');

    if (r.statusCode == 404) {
      throw Exception('Empty leg not found');
    }
    if (r.statusCode >= 400) {
      throw Exception(
        'Failed to load empty leg detail: ${r.statusCode} ${r.body}',
      );
    }

    if (r.body.trim().isEmpty) {
      throw Exception('Empty leg detail response is empty');
    }

    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return EmptyLegDetailModel.fromJson(data);
  }

  // =========================================================
  // POST /api/Reservations/emptyleg
  // =========================================================
  Future<void> reserveEmptyLeg({
    required int emptyLegFlightId,
    required double price,
    required bool lapChild,
    required bool assistanceAnimal,
    required List<Map<String, dynamic>> passengers,
    String? notes,
    required int userId, // 👈 ahora se exige el userId
  }) async {
    final headers = await _headers();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Reservations/emptyleg');

    final body = {
      'userId': userId, // 👈 mandamos el userId real al backend
      'emptyLegFlightId': emptyLegFlightId,
      'price': price,
      'lapChild': lapChild,
      'assistanceAnimal': assistanceAnimal,
      'notes': notes ?? '',
      'passengers': passengers,
    };

    debugPrint('🟠 POST $uri');
    debugPrint('🟠 Headers: $headers');
    debugPrint('🟠 Body: ${jsonEncode(body)}');

    final resp = await http.post(uri, headers: headers, body: jsonEncode(body));

    debugPrint('🟢 reserveEmptyLeg status: ${resp.statusCode}');
    debugPrint('🟢 reserveEmptyLeg body: "${resp.body}"');

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception(
        'Failed to reserve empty leg (${resp.statusCode}): ${resp.body}',
      );
    }
  }
}
