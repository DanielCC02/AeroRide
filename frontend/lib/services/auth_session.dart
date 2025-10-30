import 'token_storage.dart';
// Si en el futuro usas Dio centralizado, descomenta:
// import 'api_client.dart';

/// Centraliza el reseteo de sesión (tokens + headers en memoria).
class AuthSession {
  /// Elimina tokens persistidos y limpia headers en memoria.
  static Future<void> reset() async {
    await TokenStorage.clearTokens();

    // Si en algún momento centralizas cliente HTTP y agregas Authorization en memoria:
    // ApiClient.clearAuth(); // <- ej. para Dio
  }
}
