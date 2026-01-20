import 'dart:convert';

import 'package:frontend/models/trip.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:http/http.dart' as http;

class TripService {
  final String _baseUrl = ApiConfig.baseUrl;

  // ======================================================
  // GET: Upcoming trips del usuario
  // ======================================================
  Future<List<Trip>> getUpcomingTrips() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token no disponible");

    final url = Uri.parse("$_baseUrl/api/reservations/my/upcoming");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Trip.fromJson(e)).toList();
    }

    throw Exception(
      "Error loading upcoming trips (${response.statusCode}): ${response.body}",
    );
  }

  // ======================================================
  // GET: Past trips del usuario
  // ======================================================
  Future<List<Trip>> getPastTrips() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token no disponible");

    final url = Uri.parse("$_baseUrl/api/reservations/my/past");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Trip.fromJson(e)).toList();
    }

    throw Exception(
      "Error loading past trips (${response.statusCode}): ${response.body}",
    );
  }
}
