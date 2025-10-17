/// ===============================================================
/// AuthService (frontend)
/// ---------------------------------------------------------------
/// - Centraliza login / registro / (utilidad) verify-email.
/// - Usa SOLO tu `TokenStorage` para LEER el JWT cuando se requiere.
/// - Rutas por defecto: `/auth/login`, `/auth/register`, `/auth/verify-email`.
///   (Si tu backend expone `/api/auth/...`, cambia `_authBase`.)
///
/// Nota: El backend ya verifica al pulsar el botón del correo; dejamos
/// `verifyEmail(...)` solo para pruebas manuales (pegar token/URL).
/// ===============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';

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
  //
  // Si tu back devuelve token en el body y querés guardarlo acá,
  // descomentá el bloque indicado y AJUSTÁ el método de TokenStorage.
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

    // === (Opcional) Guardar token si tu back lo retorna en el login ===
    /*
    try {
      final data = jsonDecode(res.body);
      if (data is Map) {
        final token = (data['token'] ?? data['accessToken'] ?? data['jwt']) as String?;
        if (token != null && token.isNotEmpty) {
          // ⬇️ CAMBIÁ ESTE NOMBRE al de tu TokenStorage
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
  // Adjunta Authorization si existe un JWT (no estorba).
  // Devuelve mensaje del backend o uno por defecto.
  // Parsea ModelState y mapea errores por campo.
  // ------------------------------------------------------------
  Future<String> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    bool termsOfUse = true,
    bool privacyNotice = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$_authBase/register');

    final res = await http.post(
      uri,
      headers: await _headers(withAuth: true),
      body: jsonEncode({
        'name': name,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
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

    // ModelState / message del backend
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
      _throwKnown(
        res2,
      ); // <-- lanza; no agregamos throw extra para evitar dead code
    } else {
      _throwKnown(
        res,
      ); // <-- lanza; no agregamos throw extra para evitar dead code
    }

    // No llega aquí: _throwKnown lanza en ambos casos.
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

  /// Lanza con mensaje conocido ({error}|{message}) o genérico con código.
  Never _throwKnown(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data['error'] is String) {
        throw AuthServiceException(data['error'] as String);
      }
      if (data is Map && data['message'] is String) {
        throw AuthServiceException(data['message'] as String);
      }
    } catch (_) {}
    throw AuthServiceException('Error del servidor (HTTP ${res.statusCode}).');
  }
}
