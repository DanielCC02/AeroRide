import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../services/token_storage.dart';
import '../models/company_model.dart'; // Aquí importa el modelo CompanyModel

/// Servicio encargado de la comunicación con el backend
/// para operaciones relacionadas con empresas.
class CompanyService {
  /// Obtiene la lista de todas las empresas del sistema.
  Future<List<CompanyModel>> getAllCompanies() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/company'); // URL de la API

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Autenticación con token
      },
    );

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa (200 OK)
      final List<dynamic> data = jsonDecode(
        response.body,
      ); // Decodificar el JSON
      return data
          .map((company) => CompanyModel.fromJson(company))
          .toList(); // Convertir a lista de CompanyModel
    } else {
      print('⚠️ Error al obtener empresas: ${response.statusCode}');
      throw Exception('Error al obtener la lista de empresas');
    }
  }

  /// Crea una nueva empresa en el sistema.
  Future<CompanyModel> createCompany({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required double emptyLegDiscount,
  }) async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/company');

    // Crear el cuerpo del request
    final body = jsonEncode({
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "address": address,
      "emptyLegDiscount": emptyLegDiscount,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      // Éxito: la empresa fue creada
      final data = jsonDecode(response.body);
      return CompanyModel.fromJson(data);
    } else {
      // Error del backend
      final error = jsonDecode(response.body);
      print('⚠️ Error al crear la empresa: ${response.statusCode} → $error');
      throw Exception(error['message'] ?? 'Error al crear la empresa');
    }
  }

  /// Obtiene la información detallada de una empresa por su ID.
  Future<CompanyModel> getCompanyById(int id) async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/company/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // ✅ Éxito: decodificar y devolver la empresa
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CompanyModel.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Empresa no encontrada');
    } else {
      print('⚠️ Error al obtener empresa (status: ${response.statusCode})');
      throw Exception('Error al obtener empresa con ID $id');
    }
  }

  /// Actualiza la información de una empresa existente.
  Future<CompanyModel> updateCompany({
    required int id,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required double emptyLegDiscount,
    required bool isActive,
  }) async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/company/$id');

    final body = jsonEncode({
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "address": address,
      "emptyLegDiscount": emptyLegDiscount,
      "isActive": isActive,
    });

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CompanyModel.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Empresa no encontrada');
    } else {
      print('⚠️ Error al actualizar empresa: ${response.statusCode}');
      throw Exception(
        'Error al actualizar la empresa (status: ${response.statusCode})',
      );
    }
  }

  /// Desactiva (soft delete) una empresa existente.
  /// Equivale al endpoint DELETE /api/company/{id}
  Future<void> deactivateCompany(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/company/$id');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      print('✅ Empresa desactivada correctamente');
    } else if (response.statusCode == 404) {
      throw Exception('Empresa no encontrada');
    } else {
      throw Exception(
        'Error al desactivar la empresa (status: ${response.statusCode})',
      );
    }
  }

  /// Reactiva una empresa previamente desactivada.
  /// Equivale al endpoint PATCH /api/company/{id}/reactivate
  Future<void> reactivateCompany(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/company/$id/reactivate');

    final response = await http.patch(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      print('✅ Empresa reactivada correctamente');
    } else if (response.statusCode == 404) {
      throw Exception('Empresa no encontrada');
    } else {
      throw Exception(
        'Error al reactivar la empresa (status: ${response.statusCode})',
      );
    }
  }
}
