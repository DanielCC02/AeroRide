/// ===============================================================
/// AuthService (frontend)
/// ---------------------------------------------------------------
/// - Centraliza login / registro / (utilidad) verify-email.
/// - Usa SOLO tu `TokenStorage` para LEER el JWT cuando se requiere.
/// - Rutas por defecto: `/auth/login`, `/auth/register`, `/auth/verify-email`.
/// ===============================================================
library;

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';

extension _JsonSafe on http.Response {
  /// Intenta extraer un mensaje estándar (`message`, `detail` o `error`)
  /// desde un body JSON.
  String? tryMessage() {
    try {
      final raw = bodyBytes.isEmpty ? '' : utf8.decode(bodyBytes);
      if (raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return (decoded['message'] ?? decoded['detail'] ?? decoded['error'])
            ?.toString();
      }
    } catch (_) {
      // Silencioso: si el body no es JSON, simplemente devolvemos null.
    }
    return null;
  }
}

/// Excepción tipada para errores de Auth con soporte a ModelState.
class AuthServiceException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors; // Para ASP.NET ModelState

  AuthServiceException(this.message, {this.fieldErrors});

  @override
  String toString() => 'AuthServiceException: $message';
}

class AuthService {
  /// Cambiá a '/api/auth' si tu backend usa ese prefijo.
  static const String _authBase = '/auth';

  // ------------------------------------------------------------
  // LOGIN
  // POST /auth/login  { email, password }
  // ------------------------------------------------------------
  Future<void> login(String email, String password) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$_authBase/login');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      _throwKnown(res);
    }

    // Si tu backend retorna token aquí, podés guardarlo:
    /*
    try {
      final data = jsonDecode(res.body);
      if (data is Map) {
        final token =
            (data['token'] ?? data['accessToken'] ?? data['jwt']) as String?;
        if (token != null && token.isNotEmpty) {
          await TokenStorage.saveAccessToken(token);
        }
      }
    } catch (_) {}
    */
  }

  // ------------------------------------------------------------
  // REGISTRO
  // POST /auth/register
  //
  // Swagger actual:
  // {
  //   "name": "string",
  //   "lastName": "string",
  //   "email": "user@example.com",
  //   "password": "string",
  //   "phoneNumber": "string"
  // }
  //
  // Nosotros enviamos además:
  //   - country
  //   - termsOfUse
  //   - privacyNotice
  //
  // ASP.NET ignorará los campos extra si no están en el DTO, y si
  // agregaste Country / TermsOfUse / PrivacyNotice al DTO se mapearán.
  // ------------------------------------------------------------
  Future<String> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String country, // 👈 Nacionalidad

    bool termsOfUse = true,
    bool privacyNotice = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$_authBase/register');

    // Registro NO requiere autenticación → headers simples
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'country': country, // 👈 se envía a la API
        'termsOfUse': termsOfUse,
        'privacyNotice': privacyNotice,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data['message'] is String) {
          return data['message'] as String;
        }
      } catch (_) {}
      return 'Registro exitoso. Revisa tu correo para verificar la cuenta.';
    }

    // Manejar ASP.NET ModelState Errors
    try {
      final payload = jsonDecode(res.body);
      if (payload is Map && payload['errors'] is Map) {
        final errs = <String, List<String>>{};
        (payload['errors'] as Map).forEach((k, v) {
          final key = k.toString().toLowerCase();
          if (v is List) {
            errs[key] = v.map((e) => e.toString()).toList();
          } else if (v != null) {
            errs[key] = [v.toString()];
          }
        });
        throw AuthServiceException('Errores de validación', fieldErrors: errs);
      }
      if (payload is Map && payload['message'] is String) {
        throw AuthServiceException(payload['message'] as String);
      }
    } catch (_) {}

    throw AuthServiceException(
      'No se pudo completar el registro (HTTP ${res.statusCode}).',
    );
  }

  // ------------------------------------------------------------
  // FORGOT PASSWORD
  // POST /auth/forgot-password  { email }
  // ------------------------------------------------------------
  Future<bool> requestPasswordReset(String email) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$_authBase/forgot-password');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return true; // OK (text/plain)
    }

    // Intentar extraer mensaje del backend
    final msg = res.tryMessage();
    if (msg != null && msg.isNotEmpty) {
      final low = msg.toLowerCase();
      if (low.contains('not registered') ||
          low.contains('not found') ||
          low.contains('no existe') ||
          low.contains('no registrado')) {
        throw AuthServiceException('This email is not registered');
      }
      throw AuthServiceException(msg);
    }

    if (res.statusCode == 400 || res.statusCode == 404) {
      throw AuthServiceException('This email is not registered');
    }

    throw AuthServiceException(
      'Unable to send reset email (HTTP ${res.statusCode}).',
    );
  }

  // ------------------------------------------------------------
  // RESET PASSWORD
  // PUT /auth/reset-password  { token, newPassword }
  // ------------------------------------------------------------
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$_authBase/reset-password');

    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'newPassword': newPassword}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) return;

    final msg = res.tryMessage();
    if (msg != null && msg.isNotEmpty) {
      throw AuthServiceException(msg);
    }

    throw AuthServiceException(
      'Could not reset password (HTTP ${res.statusCode}).',
    );
  }

  // ------------------------------------------------------------
  // VERIFICAR EMAIL (utilidad para pruebas manuales)
  // GET  /auth/verify-email?token=...
  // POST /auth/verify-email { token }
  // ------------------------------------------------------------
  Future<String> verifyEmail({required String token}) async {
    final t = _extractToken(token);
    if (t.isEmpty) {
      throw AuthServiceException('No se encontró un token válido.');
    }

    final headers = await _headers(withAuth: true);

    // 1) GET
    final getUri = Uri.parse(
      '${ApiConfig.baseUrl}$_authBase/verify-email?token=${Uri.encodeComponent(t)}',
    );
    http.Response res = await http.get(getUri, headers: headers);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return _okMessage(res.body);
    }

    // 2) Si GET no existe/permitido, intenta POST
    if (res.statusCode == 404 || res.statusCode == 405) {
      final postUri = Uri.parse('${ApiConfig.baseUrl}$_authBase/verify-email');
      final res2 = await http.post(
        postUri,
        headers: headers,
        body: jsonEncode({'token': t}),
      );
      if (res2.statusCode >= 200 && res2.statusCode < 300) {
        return _okMessage(res2.body);
      }
      _throwKnown(res2); // lanza siempre (Never)
    } else {
      _throwKnown(res); // lanza siempre (Never)
    }
  }

  // ======================== Helpers =========================

  Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        h['Authorization'] = 'Bearer $token';
      }
    }
    return h;
  }

  String _extractToken(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return '';

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      try {
        final uri = Uri.parse(raw);
        final q = uri.queryParameters['token'];
        if (q != null && q.isNotEmpty) return q;
      } catch (_) {}
    }

    final idx = raw.indexOf('token=');
    if (idx != -1) {
      try {
        final uri = Uri.parse('http://x.x/?${raw.substring(idx)}');
        final q = uri.queryParameters['token'];
        if (q != null && q.isNotEmpty) return q;
      } catch (_) {}
    }

    return raw; // ya es token plano
  }

  String _okMessage(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    } catch (_) {}
    return 'Operación realizada correctamente.';
  }

  /// Lanza con mensaje conocido ({error}|{message}|{detail}) o genérico con código.
  Never _throwKnown(http.Response res) {
    final msg = res.tryMessage();
    if (msg != null && msg.isNotEmpty) {
      throw AuthServiceException(msg);
    }
    throw AuthServiceException('Error del servidor (HTTP ${res.statusCode}).');
  }

  // refresh con /auth/refresh
  Future<bool> refreshToken() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    final uri = Uri.parse('${ApiConfig.baseUrl}$_authBase/refresh');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refresh}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final data = jsonDecode(res.body);
        final access = (data['accessToken'] ?? data['token'])?.toString();
        final newRefresh = (data['refreshToken'])?.toString();
        if (access != null && access.isNotEmpty) {
          await TokenStorage.saveAccessToken(access);
        }
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await TokenStorage.saveRefreshToken(newRefresh);
        }
        return true;
      } catch (_) {
        return false;
      }
    }

    // Si falla, limpiar para evitar loops
    await TokenStorage.clearTokens();
    return false;
  }
}

// ===============================================================
// UserModel
// ===============================================================
class UserModel {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;
  final bool isActive;
  final String fullName;
  final String? companyName;
  final String? registrationDate;
  final bool? termsOfUse;
  final bool? privacyNotice;
  final String? country;

  UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.isActive,
    required this.fullName,
    this.companyName,
    this.registrationDate,
    this.termsOfUse,
    this.privacyNotice,
    this.country,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? false,
      companyName: json['companyName'],
      fullName: '${json['name'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      registrationDate: json['registrationDate'],
      termsOfUse: json['termsOfUse'],
      privacyNotice: json['privacyNotice'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'isActive': isActive,
      'fullName': fullName,
      'companyName': companyName,
      'registrationDate': registrationDate,
      'termsOfUse': termsOfUse,
      'privacyNotice': privacyNotice,
      'country': country,
    };
  }
}
