import 'dart:convert';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:http/http.dart' as http;
import '../models/airport_model.dart';

class AirportService {
  final http.Client _client;
  AirportService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Airport>> getActiveAirports() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/airports'); // <--- AQUÍ
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final token = await TokenStorage.getAccessToken(); // <--- JWT del login
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final resp = await _client.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      final list = (jsonDecode(resp.body) as List)
          .map((j) => Airport.fromJson(j as Map<String, dynamic>))
          .toList();
      return list;
    }
    throw Exception('GET ${uri.path} -> ${resp.statusCode} ${resp.body}');
  }

  void dispose() => _client.close();
}
