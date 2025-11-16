import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:frontend/services/api_config.dart';

/// Servicio encargado de obtener los vuelos asociados a una compañía.
/// Endpoint: GET /api/flights/company/{companyId}
class CompanyFlightService {
  /// Obtiene todos los vuelos de una compañía específica.
  /// Retorna una lista de [CompanyFlightModel].
  Future<List<CompanyFlightModel>> getFlightsByCompany(int companyId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    // 🔹 Usamos la URL base centralizada (igual que los otros servicios)
    final url = Uri.parse('${ApiConfig.baseUrl}/api/flights/company/$companyId');

    print('📡 GET $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 Status: ${response.statusCode}');
    print('📥 Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => CompanyFlightModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('❌ Error al parsear vuelos: $e');
        throw Exception('Error al procesar los datos del servidor');
      }
    } else if (response.statusCode == 204) {
      print('No hay vuelos registrados para esta compañía.');
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado. Verifica tu sesión.');
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado. No tienes permisos para esta acción.');
    } else {
      print('⚠️ Error al obtener vuelos: ${response.body}');
      throw Exception(
          'Error al obtener vuelos (${response.statusCode}): ${response.body}');
    }
  }
  // ======================================================
  // POST: Asignar piloto y copiloto a un vuelo
  // ======================================================
  Future<void> assignPilotsToFlight({
    required int flightId,
    required int pilotId,
    int? coPilotId,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/flights/$flightId/assign');

    final body = {
      'pilotId': pilotId,
      if (coPilotId != null) 'coPilotId': coPilotId,
    };

    print('🛫 POST $url');
    print('📤 Body: $body');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('📥 Status: ${response.statusCode}');
    print('📥 Body: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Pilotos asignados correctamente.');
    } else {
      final msg = response.body.isNotEmpty ? response.body : 'Error desconocido';
      throw Exception('❌ Error al asignar pilotos: $msg');
    }
  }
}

