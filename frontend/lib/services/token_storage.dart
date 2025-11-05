import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyCompanyId = 'company_id';
  static const _keyCompanyName = 'company_name'; // Nuevo

  // ======================================================
  // 🔐 TOKENS
  // ======================================================

  /// Guarda ambos tokens (access + refresh)
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  /// Guarda SOLO el access token (útil si haces refresh)
  static Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
  }

  /// Guarda SOLO el refresh token (útil si haces refresh)
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  /// Obtiene el access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Obtiene el refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Retorna true si hay algún token persistido
  static Future<bool> hasTokens() async {
    final a = await _storage.read(key: _keyAccessToken);
    final r = await _storage.read(key: _keyRefreshToken);
    return (a != null && a.isNotEmpty) || (r != null && r.isNotEmpty);
  }

  // ======================================================
  // 🏢 COMPANY ID & NAME
  // ======================================================

  /// Guarda el ID de la compañía asociada al usuario (solo CompanyAdmins)
  static Future<void> saveCompanyId(int? companyId) async {
    if (companyId != null) {
      await _storage.write(key: _keyCompanyId, value: companyId.toString());
    } else {
      await _storage.delete(key: _keyCompanyId);
    }
  }

  /// Obtiene el companyId guardado (si existe)
  static Future<int?> getCompanyId() async {
    final value = await _storage.read(key: _keyCompanyId);
    return value != null ? int.tryParse(value) : null;
  }

  /// Guarda el nombre de la compañía
  static Future<void> saveCompanyName(String? companyName) async {
    if (companyName != null) {
      await _storage.write(key: _keyCompanyName, value: companyName);
    } else {
      await _storage.delete(key: _keyCompanyName);
    }
  }

  /// Obtiene el nombre de la compañía guardado (si existe)
  static Future<String?> getCompanyName() async {
    return await _storage.read(key: _keyCompanyName);
  }

  // ======================================================
  // 🚪 LIMPIEZA
  // ======================================================

  /// Elimina tokens y companyId (por ejemplo al cerrar sesión o al volver al Welcome)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyCompanyId);
    await _storage.delete(key: _keyCompanyName); // Nuevo
  }
}
