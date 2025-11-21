import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/flight_assigned_pilot_model.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/api_config.dart';
import '../services/token_storage.dart';

/// Servicio encargado de la comunicación con el backend
/// para operaciones relacionadas con usuarios (solo accesible por admin).
class UserService {
  /// Crea un nuevo usuario en el sistema (solo administradores o CompanyAdmin).
  Future<void> createUser({
    required String name,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required int roleId,
    int? companyId,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users');

    final body = {
      'name': name,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'roleId': roleId,
      if (companyId != null) 'companyId': companyId,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      debugPrint('✅ Usuario creado correctamente');
    } else {
      debugPrint('❌ Error al crear usuario: ${response.body}');
      throw Exception('Error al crear el usuario');
    }
  }

  /// Obtiene todos los administradores de una empresa específica.
  Future<List<UserModel>> getCompanyAdmins(int companyId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    // CORRECTA: Mayúscula en "Users" y plural "admins"
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/Users/company/$companyId/admins',
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('GET $url');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((user) => UserModel.fromJson(user)).toList();
      } catch (e) {
        debugPrint('❌ Error al parsear JSON: $e');
        throw Exception('Formato de datos inválido del servidor');
      }
    } else {
      debugPrint('⚠️ Error al obtener administradores: ${response.body}');
      throw Exception('Error al obtener los administradores de la empresa');
    }
  }

  /// Obtiene todos los pilotos pertenecientes a una compañía específica
  Future<List<UserModel>> getPilotsByCompany(int companyId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/company/$companyId/pilots',
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => UserModel.fromJson(user)).toList();
    } else {
      debugPrint('⚠️ Error loading pilots: ${response.body}');
      throw Exception('Error getting pilots for the company');
    }
  }

  /// Obtiene solo los pilotos ACTIVOS pertenecientes a una compañía específica
  Future<List<UserModel>> getActivePilotsByCompany(int companyId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/company/$companyId/pilots/active',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => UserModel.fromJson(user)).toList();
    } else {
      debugPrint('⚠️ Error loading ACTIVE pilots: ${response.body}');
      throw Exception('Error getting active pilots for the company');
    }
  }

  /// Obtiene los pilotos ya asignados a un vuelo específico
  Future<List<FlightAssignedPilotModel>> getAssignedPilotsByFlight(
    int flightId,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/flights/$flightId/pilots');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => FlightAssignedPilotModel.fromJson(p)).toList();
    } else {
      throw Exception('Error getting assigned pilots for flight');
    }
  }

  /// ===========================================================
  /// Actualiza la información de un piloto (solo para CompanyAdmin)
  /// ===========================================================
  Future<void> updatePilotByCompanyAdmin({
    required int id, // ID del piloto
    required String name,
    required String lastName,
    required String email,
    required String phoneNumber,
    bool? isActive, // opcional: activar/desactivar piloto
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    // URL del endpoint
    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id');

    // Armamos el cuerpo
    final body = {
      'name': name,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'roleId': 3, // siempre Piloto
      if (isActive != null) 'isActive': isActive,
    };

    debugPrint('PUT $url');
    debugPrint('Body enviado: $body');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Response: ${response.body}');

    if (response.statusCode == 200) {
      debugPrint('✅ Piloto actualizado correctamente');
    } else if (response.statusCode == 404) {
      throw Exception('❌ Piloto no encontrado');
    } else {
      throw Exception('❌ Error al actualizar piloto: ${response.body}');
    }
  }

  // ===========================================================
  // GET: Obtener usuario (admin de compañía) por ID
  // ===========================================================
  Future<UserModel> getCompanyAdminById(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id');

    debugPrint('👤 GET $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint(
        '✅ Usuario obtenido correctamente: ${data['name'] ?? data['email']}',
      );
      return UserModel.fromJson(data);
    } else if (response.statusCode == 404) {
      debugPrint('⚠️ Usuario con ID $id no encontrado');
      throw Exception('Usuario no encontrado');
    } else {
      debugPrint('❌ Error al obtener detalle del usuario: ${response.body}');
      throw Exception(
        'Error al obtener detalle del usuario (status: ${response.statusCode})',
      );
    }
  }

  // ===========================================================
  // PUT: Actualizar información del administrador de compañía
  // ===========================================================
  Future<void> updateCompanyAdmin({
    required int id, // ID del administrador
    required String name,
    required String lastName,
    required String email,
    required String phoneNumber,
    bool? isActive, // opcional: activar/desactivar
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id');

    final body = {
      'name': name,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'roleId': 2, // Rol fijo: CompanyAdmin
      if (isActive != null) 'isActive': isActive,
    };

    debugPrint('PUT $url');
    debugPrint('Body enviado: $body');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    debugPrint('📥 Status: ${response.statusCode}');
    debugPrint('📥 Response: ${response.body}');

    if (response.statusCode == 200) {
      debugPrint('✅ Administrador de compañía actualizado correctamente');
    } else if (response.statusCode == 404) {
      throw Exception('❌ Administrador no encontrado');
    } else if (response.statusCode == 400) {
      throw Exception('❌ Datos inválidos: ${response.body}');
    } else {
      throw Exception(
        '❌ Error al actualizar administrador (status: ${response.statusCode})',
      );
    }
  }

  /// Obtiene el detalle de un usuario por su ID.
  Future<UserModel> getUserById(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    } else {
      throw Exception('Error al obtener detalle del usuario');
    }
  }

  /// Actualiza la información de un usuario específico (solo para administradores).
  Future<void> updateUserByAdmin({
    required int id,
    required String name,
    required String lastName,
    required String email,
    required String role, // 'Admin', 'Pilot', 'User', 'CompanyAdmin'
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id');

    // Convertir nombre de rol a id
    final Map<String, int> roleIds = {
      'Admin': 1,
      'CompanyAdmin': 2,
      'Pilot': 3,
      'User': 4,
    };

    final roleId = roleIds[role] ?? 4;

    final body = {
      'name': name,
      'lastName': lastName,
      'email': email,
      'roleId': roleId,
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
      debugPrint('✅ Usuario actualizado correctamente');
    } else {
      debugPrint('❌ Error al actualizar usuario: ${response.body}');
      throw Exception('Error al actualizar usuario');
    }
  }

  /// Desactiva un usuario (soft delete) — solo para administradores.
  Future<void> deactivateUser(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Usuario desactivado correctamente');
    } else {
      debugPrint('❌ Error al desactivar usuario: ${response.body}');
      throw Exception('Error al desactivar usuario');
    }
  }

  /// Reactiva un usuario previamente desactivado (solo para administradores).
  Future<void> reactivateUser(int id) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id/reactivate');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Usuario reactivado correctamente');
    } else {
      debugPrint('❌ Error al reactivar usuario: ${response.body}');
      throw Exception('Error al reactivar usuario');
    }
  }

  /// Obtiene la lista de todos los usuarios del sistema.
  Future<List<UserModel>> getAllUsers() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => UserModel.fromJson(user)).toList();
    } else {
      debugPrint('⚠️ Error al obtener usuarios: ${response.statusCode}');
      throw Exception('Error al obtener la lista de usuarios');
    }
  }
}
