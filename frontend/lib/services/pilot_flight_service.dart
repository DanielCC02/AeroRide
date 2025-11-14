import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/token_storage.dart';

class PilotFlightService {
  Future<List<CompanyFlightModel>> getFlightsByPilot(int pilotId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token no disponible");

    final url = Uri.parse("${ApiConfig.baseUrl}/api/flights/pilot/$pilotId");

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
}
