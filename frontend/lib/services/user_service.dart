import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../services/token_storage.dart';
import '../models/user_model.dart';

/// Servicio encargado de la comunicación con el backend
/// para operaciones relacionadas con usuarios (solo accesible por admin).
class UserService {
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
      print('⚠️ Error al obtener usuarios: ${response.statusCode}');
      throw Exception('Error al obtener la lista de usuarios');
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

  /// Crea un nuevo usuario en el sistema (solo administradores).
  Future<void> createUser({
    required String name,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required int roleId,
    required bool termsOfUse,
    required bool privacyNotice,
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
      'termsOfUse': termsOfUse,
      'privacyNotice': privacyNotice,
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
      print('✅ Usuario creado correctamente');
    } else {
      print('❌ Error al crear usuario: ${response.body}');
      throw Exception('Error al crear el usuario');
    }
  }

  /// Actualiza la información de un usuario específico (solo para administradores).
  Future<void> updateUserByAdmin({
    required int id,
    required String fullName,
    required String email,
    required String role, // 'Admin', 'Pilot', 'User'
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$id');

    // 👇 Dividir nombre y apellido
    final parts = fullName.trim().split(' ');
    final name = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    // 👇 Convertir nombre de rol → id
    final Map<String, int> roleIds = {
      'Admin': 1,
      'Broker': 2,
      'Pilot': 3,
      'User': 4,
    };

    final roleId = roleIds[role] ?? 4; // Por defecto: User

    final body = {
      'name': name,
      'lastName': lastName,
      'email': email,
      'roleId': roleId, // 👈 Enviamos ID, no nombre
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
      print('✅ Usuario actualizado correctamente');
    } else {
      print('❌ Error al actualizar usuario: ${response.body}');
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
      print('✅ Usuario desactivado correctamente');
    } else {
      print('❌ Error al desactivar usuario: ${response.body}');
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
      print('✅ Usuario reactivado correctamente');
    } else {
      print('❌ Error al reactivar usuario: ${response.body}');
      throw Exception('Error al reactivar usuario');
    }
  }
}
