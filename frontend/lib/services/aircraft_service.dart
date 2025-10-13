import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/aircraft_model.dart';
import '../services/token_storage.dart';
import '../services/api_config.dart';

/// Servicio encargado de manejar todas las operaciones
/// relacionadas con aeronaves (Fleet Management).
class AircraftService {
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
  // POST: Crear una nueva aeronave
  // ===========================================================
  Future<void> createAircraft({
    required String patent,
    required String model,
    required double price,
    required int seats,
    required int maxWeight,
    required String state,
    String? image, // opcional
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts');

    final body = {
      'patent': patent,
      'model': model,
      'price': price,
      'seats': seats,
      'maxWeight': maxWeight,
      'state': state,
      'image': image ?? '', // puede ser vacío por ahora
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

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

    final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts/ImageUpload');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl']; // devuelve la URL pública
    } else {
      print('❌ Error al subir imagen: ${response.body}');
      throw Exception('Error al subir imagen');
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
  // PUT: Actualizar aeronave
  // ===========================================================
  Future<void> updateAircraft({
    required int id,
    required String patent,
    required String model,
    required double price,
    required int seats,
    required int maxWeight,
    required String state,
    String? imageUrl,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/aircrafts/$id');

    final body = {
      'patent': patent,
      'model': model,
      'price': price,
      'seats': seats,
      'maxWeight': maxWeight,
      'state': state,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
    };

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('✅ Aeronave actualizada correctamente');
    } else {
      print('❌ Error al actualizar aeronave: ${response.body}');
      throw Exception('Error al actualizar aeronave');
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
