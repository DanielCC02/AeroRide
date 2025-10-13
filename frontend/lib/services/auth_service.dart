import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

/// =============================================================
/// AUTH SERVICE
/// =============================================================
/// 
/// Servicio responsable de manejar la comunicación entre
/// la aplicación Flutter y los endpoints de autenticación
/// del backend (login, registro, refresh, logout, etc.).
///
/// En este caso, implementa solo el método `login`,
/// pero la idea es escalarlo para incluir todos los métodos
/// relacionados con la autenticación del usuario.
///
/// =============================================================
class AuthService {
  Future<void> login(String email, String password) async {
/// Construye la URL completa del endpoint de login
/// usando la base definida en [ApiConfig].
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

/// Envía una solicitud HTTP POST con las credenciales
/// del usuario (email y password) en formato JSON.
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    /// Espera la respuesta del backend:
    print('Código: ${response.statusCode}'); 
    /// Muestra el código de respuesta y el cuerpo (body)
    print('Respuesta: ${response.body}');
  }
  /// =============================================================
/// NOTAS:
/// - En una versión posterior, este método debería:
///  Guardar el token JWT usando [TokenStorage].
///  Retornar los datos del usuario autenticado.
/// =============================================================
}
