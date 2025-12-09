/// =============================================================
/// API CONFIGURATION
/// =============================================================
/// Centraliza la URL base que usarán todos los servicios HTTP.
///
/// ⚠ Android Emulator → usa 10.0.2.2 para alcanzar el localhost del PC.
/// Si pruebas en iOS Simulator, puedes usar http://localhost:<#puerto>.
/// Si pruebas en un teléfono físico, usa la IP LAN de tu PC, ej. http://192.168.x.x:<#puerto>.
/// =============================================================
class ApiConfig {
static const String baseUrl = 'http://192.168.0.16:5192';
}

// Tomas
//class ApiConfig {
//  static const String baseUrl = 'http://192.168.0.10:5192';
//}
