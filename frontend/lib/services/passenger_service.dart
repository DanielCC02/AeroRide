// lib/services/passenger_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';
import '../models/passenger_detail_dto.dart';

class PassengerServiceException implements Exception {
  final String message;
  final int? status;
  PassengerServiceException(this.message, {this.status});
}

class PassengerService {
  PassengerService._();
  static final PassengerService _i = PassengerService._();
  factory PassengerService() => _i;

  Future<Map<String, String>> _headers() async {
    final t = await TokenStorage.getAccessToken();
    if (t == null || t.isEmpty) {
      throw PassengerServiceException('Sesión expirada.', status: 401);
    }
    return {
      'Authorization': 'Bearer $t',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Crea en bulk los pasajeros para una reserva.
  /// Intenta rutas tolerantes para tu backend actual.
  Future<void> createForReservation(
    int reservationId,
    List<PassengerDetailDto> pax,
  ) async {
    if (pax.isEmpty) return;
    final h = await _headers();

    // 1) /api/reservations/{id}/passengers
    try {
      final u = Uri.parse(
        '${ApiConfig.baseUrl}/api/reservations/$reservationId/passengers',
      );
      final r = await http.post(
        u,
        headers: h,
        body: jsonEncode(pax.map((e) => e.toJson()).toList()),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) return;
    } catch (_) {}

    // 2) /api/passenger-details (bulk)
    try {
      final u = Uri.parse('${ApiConfig.baseUrl}/api/passenger-details');
      final r = await http.post(
        u,
        headers: h,
        body: jsonEncode(pax.map((e) => e.toJson()).toList()),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) return;
    } catch (_) {}

    // 3) /api/passengers (uno a uno)
    for (final p in pax) {
      final u = Uri.parse('${ApiConfig.baseUrl}/api/passengers');
      final r = await http.post(u, headers: h, body: jsonEncode(p.toJson()));
      if (r.statusCode < 200 || r.statusCode >= 300) {
        throw PassengerServiceException(
          'Error guardando un pasajero (HTTP ${r.statusCode}).',
          status: r.statusCode,
        );
      }
    }
  }
}
