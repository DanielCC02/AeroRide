import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/aircraft_model.dart';
import '../services/token_storage.dart';
import '../services/api_config.dart';

/// Servicio encargado de manejar todas las operaciones
/// relacionadas con aeronaves (Fleet Management).
class AircraftService {

  /// Obtiene todas las aeronaves (activas e inactivas) de una compañía específica.
  Future<List<AircraftModel>> getAircraftsByCompany(int companyId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/Aircrafts/company/$companyId/all');

    print('📡 GET $url'); // <-- debug
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
        return data.map((a) => AircraftModel.fromJson(a)).toList();
      } catch (e) {
        print('Error al parsear aeronaves: $e');
        throw Exception('Error al procesar los datos del servidor');
      }
    } else if (response.statusCode == 204) {
      // Sin contenido (NoContent)
      print('No hay aeronaves registradas para esta compañía.');
      return [];
    } else {
      print('⚠️ Error al obtener aeronaves: ${response.body}');
      throw Exception('Error al obtener las aeronaves de la compañía');
    }
  }

// ===========================================================
// POST: Crear una nueva aeronave (asociada a una compañía)
// ===========================================================
Future<void> createAircraft({
  // 🔑 Identificación
  required String patent,
  required String model,

  // 💰 Características técnicas
  required double minuteCost,
  required int seats,
  required int emptyWeight,
  required int maxWeight,
  required double cruisingSpeed,
  required bool canFlyInternational,

  // ⚙️ Estado técnico
  required String state,
  String? image, // opcional

  // 🌎 Ubicación y relaciones
  required int baseAirportId,
  int? currentAirportId, // opcional
  required int companyId, // siempre requerido por backend
}) async {
  final token = await TokenStorage.getAccessToken();
  if (token == null) throw Exception('Token no disponible');

  final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts');

  final body = {
    'patent': patent,
    'model': model,
    'minuteCost': minuteCost,
    'seats': seats,
    'emptyWeight': emptyWeight,
    'maxWeight': maxWeight,
    'cruisingSpeed': cruisingSpeed,
    'canFlyInternational': canFlyInternational,
    'state': state,
    'image': image ?? '', // puede ser vacío
    'baseAirportId': baseAirportId,
    'companyId': companyId,
    if (currentAirportId != null) 'currentAirportId': currentAirportId,
  };

  print('🚀 POST $url');
  print('📤 Body enviado: $body');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  print('📥 Status: ${response.statusCode}');
  print('📥 Response: ${response.body}');

  if (response.statusCode == 201) {
    print('✅ Aeronave creada correctamente');
  } else {
    print('❌ Error al crear aeronave: ${response.body}');
    throw Exception('Error al crear aeronave');
  }
}

 // ===========================================================
//  POST: Subir imagen de aeronave (opcional)
// ===========================================================
Future<String> uploadAircraftImage(File imageFile) async {
  final token = await TokenStorage.getAccessToken();
  if (token == null) throw Exception('Token no disponible');

  // 👇 Ruta correcta según tu backend
  final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts/upload-image');

  final request = http.MultipartRequest('POST', url)
    ..headers['Authorization'] = 'Bearer $token'
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  print('📤 Subiendo imagen a: $url');
  print('🖼️ Archivo: ${imageFile.path}');

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  print('📥 Status: ${response.statusCode}');
  print('📥 Body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['imageUrl'];
  } else {
    final body = response.body.isNotEmpty ? response.body : 'Respuesta vacía';
    throw Exception(
        'Error al subir imagen (status: ${response.statusCode}) → $body');
  }
}


  // ===========================================================
  // GET: Obtener todas las aeronaves (activas e inactivas)
  // ===========================================================
  Future<List<AircraftModel>> getAllAircrafts() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts/all');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => AircraftModel.fromJson(e)).toList();
    } else if (response.statusCode == 204) {
      // No hay aeronaves registradas
      return [];
    } else {
      print('❌ Error al obtener aeronaves: ${response.body}');
      throw Exception(
        'Error al obtener aeronaves (status ${response.statusCode})',
      );
    }
  }

  // ===========================================================
  // GET: Obtener aeronave por ID
  // ===========================================================
  Future<AircraftModel> getAircraftById(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts/$id');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AircraftModel.fromJson(json);
    } else if (response.statusCode == 404) {
      throw Exception('Aeronave no encontrada');
    } else {
      print('❌ Error al obtener aeronave: ${response.body}');
      throw Exception('Error al obtener aeronave');
    }
  }

  // ===========================================================
// PUT: Actualizar aeronave (excepto compañía)
// ===========================================================
Future<void> updateAircraft({
  required int id,
  required String patent,
  required String model,
  required double minuteCost,
  required int seats,
  required int emptyWeight,
  required int maxWeight,
  required double cruisingSpeed,
  required bool canFlyInternational,
  required String state,
  required int baseAirportId,
  int? currentAirportId,
  String? imageUrl,
}) async {
  final token = await TokenStorage.getAccessToken();
  if (token == null) throw Exception('Token no disponible');

  final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts/$id');

  final body = {
    'patent': patent,
    'model': model,
    'minuteCost': minuteCost,
    'seats': seats,
    'emptyWeight': emptyWeight,
    'maxWeight': maxWeight,
    'cruisingSpeed': cruisingSpeed,
    'canFlyInternational': canFlyInternational,
    'state': state,
    'baseAirportId': baseAirportId,
    if (currentAirportId != null) 'currentAirportId': currentAirportId,
    if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
  };

  print('🛠️ PUT $url');
  print('📦 Body: $body');

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  print('📥 Status: ${response.statusCode}');
  print('📥 Response: ${response.body}');

  if (response.statusCode == 200) {
    print('✅ Aeronave actualizada correctamente');
  } else if (response.statusCode == 404) {
    throw Exception('Aeronave no encontrada');
  } else if (response.statusCode == 400) {
    throw Exception('Datos inválidos: ${response.body}');
  } else {
    throw Exception('Error al actualizar aeronave (${response.statusCode})');
  }
}

  // ======================================================
  // 🔻 Desactivar aeronave
  // ======================================================
  Future<void> deactivateAircraft(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('✅ Aeronave desactivada correctamente');
    } else {
      print('❌ Error al desactivar aeronave: ${response.body}');
      throw Exception('Error al desactivar aeronave');
    }
  }

  // ======================================================
  // 🔄 Reactivar aeronave
  // ======================================================
  Future<void> reactivateAircraft(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts/reactivate/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('✅ Aeronave reactivada correctamente');
    } else {
      print('❌ Error al reactivar aeronave: ${response.body}');
      throw Exception('Error al reactivar aeronave');
    }
  }
}
