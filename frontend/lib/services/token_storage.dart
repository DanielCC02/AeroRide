import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  /// Guarda ambos tokens
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  /// Obtiene el access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Elimina los tokens (por ejemplo al cerrar sesión)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }
}
