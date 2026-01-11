/// =============================================================
/// API CONFIGURATION
/// =============================================================
/// Centraliza la URL base que usarán todos los servicios HTTP.
///
/// ⚠ Android Emulator → usa 10.0.2.2 para alcanzar el localhost del PC.
/// Si pruebas en iOS Simulator, puedes usar http://localhost:<puerto>.
/// Si pruebas en un teléfono físico, usa la IP LAN de tu PC, ej. http://192.168.x.x:<puerto>.
/// =============================================================
class ApiConfig {
  /// Para Android Emulator + backend en tu PC con dotnet run en http://localhost:5192
  //static const String baseUrl = 'http://10.0.2.2:5192';

  // Ejemplos alternativos:
  // static const String baseUrl = 'http://localhost:5192';          // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.34:5192';       // Teléfono físico en misma Wi-Fi
  // static const String baseUrl = 'https://<tu-dominio>.ngrok.app'; // Túnel HTTPS
  //}

  // Tomas
  //class ApiConfig {
  static const String baseUrl = 'http://192.168.1.17:5192';
}
