import 'dart:convert';
import 'dart:io';

import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/models/flight_log_model.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:http/http.dart' as http;

class PilotFlightService {
  final String _baseUrl = ApiConfig.baseUrl;

  // ======================================================
  // GET: Vuelos asignados a un piloto
  // ======================================================
  Future<List<CompanyFlightModel>> getFlightsByPilot(int pilotId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token no disponible");

    final url = Uri.parse("$_baseUrl/api/flights/pilot/$pilotId");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => CompanyFlightModel.fromJson(e)).toList();
    }

    throw Exception(
      "Error loading pilot flights (${response.statusCode}): ${response.body}",
    );
  }

  // ======================================================
  // POST: Guardar bitácora (PDF)
  // ======================================================
  Future<FlightLogModel> saveFlightLog({
    required int flightId,
    required int pilotUserId,
    required File pdfFile,
  }) async {
    final uri = Uri.parse("$_baseUrl/api/flightlogs");
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token no disponible");

    final request = http.MultipartRequest("POST", uri);

    // Headers
    request.headers['Authorization'] = "Bearer $token";

    // Campos de texto
    request.fields['flightId'] = flightId.toString();
    request.fields['pilotUserId'] = pilotUserId.toString();

    // Archivo PDF
    request.files.add(
      await http.MultipartFile.fromPath(
        'pdfFile',
        pdfFile.path,
        filename: pdfFile.path.split("/").last,
      ),
    );

    final streamedRes = await request.send();
    final res = await http.Response.fromStream(streamedRes);

    if (res.statusCode != 200) {
      throw Exception("Error uploading log: ${res.body}");
    }

    final json = jsonDecode(res.body);
    return FlightLogModel.fromJson(json);
  }

  // ======================================================
  // GET: Obtener bitácora por vuelo
  // ======================================================
  Future<FlightLogModel?> getFlightLogByFlight(int flightId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw Exception("Token not available");
    }

    final url = Uri.parse("$_baseUrl/api/flightlogs/flight/$flightId");

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    // 👉 Si backend devuelve 204 (NoContent) = no hay bitácora
    if (response.statusCode == 204) {
      return null;
    }

    if (response.statusCode == 200) {
      if (response.body.isEmpty ||
          response.body == 'null' ||
          response.body.trim().isEmpty) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return FlightLogModel.fromJson(data);
    }

    // Si usas 404 en algún momento, también lo tratamos como "no hay log"
    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(
      'Error getting flight log: ${response.statusCode} - ${response.body}',
    );
  }

  // ======================================================
  // Saber si un vuelo tiene bitácora (true/false)
  // ======================================================
  Future<bool> flightHasLog(int flightId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw Exception("Token not available");
    }

    final url = Uri.parse("$_baseUrl/api/flightlogs/flight/$flightId");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    // 204 = NoContent → NO hay bitácora
    if (response.statusCode == 204) {
      return false;
    }

    // 200 = hay bitácora
    if (response.statusCode == 200) {
      return true;
    }

    // 404 (si lo usas así) → tampoco hay log
    if (response.statusCode == 404) {
      return false;
    }

    // Cualquier otra cosa = error real
    throw Exception(
      "Error checking log (${response.statusCode}): ${response.body}",
    );
  }
}
