// lib/services/reservation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/reservation_estimate_request.dart';
import '../models/reservation_estimate_response.dart';
import '../models/reservation_create_request.dart';
import 'api_config.dart';
import 'token_storage.dart';

class ReservationServiceException implements Exception {
  final int? statusCode;
  final String message;
  ReservationServiceException(this.message, {this.statusCode});
  @override
  String toString() =>
      'ReservationServiceException(${statusCode ?? '-'}): $message';
}

class ReservationService {
  Future<ReservationEstimateResponse> estimate(
    ReservationEstimateRequest req,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw ReservationServiceException('Token no disponible');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/Reservations/estimate');
    final body = jsonEncode(req.toJson());
    // Logs útiles
    // ignore: avoid_print
    print('[ESTIMATE] POST $url');
    // ignore: avoid_print
    print('[ESTIMATE] Body: $body');

    final r = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (r.statusCode == 200) {
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      return ReservationEstimateResponse.fromJson(data);
    }

    // Parsear {message}|{detail} si viene
    String detail;
    try {
      final data = jsonDecode(r.body);
      if (data is Map) {
        detail = (data['message'] ?? data['detail'] ?? r.body).toString();
      } else {
        detail = r.body.isNotEmpty ? r.body : 'sin detalle';
      }
    } catch (_) {
      detail = r.body.isNotEmpty ? r.body : 'sin detalle';
    }

    throw ReservationServiceException(
      'Error en estimate: $detail',
      statusCode: r.statusCode,
    );
  }

  Future<void> create(ReservationCreateRequest req) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw ReservationServiceException('Token no disponible');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/Reservations');
    final body = jsonEncode(req.toJson());
    // ignore: avoid_print
    print('[CREATE] POST $url');
    // ignore: avoid_print
    print('[CREATE] Body: $body');

    final r = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (r.statusCode == 201) return;

    String detail;
    try {
      final data = jsonDecode(r.body);
      if (data is Map) {
        detail = (data['message'] ?? data['detail'] ?? r.body).toString();
      } else {
        detail = r.body.isNotEmpty ? r.body : 'sin detalle';
      }
    } catch (_) {
      detail = r.body.isNotEmpty ? r.body : 'sin detalle';
    }

    throw ReservationServiceException(
      'Error al crear la reserva: $detail',
      statusCode: r.statusCode,
    );
  }
}
