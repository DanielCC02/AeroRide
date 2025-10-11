/// =============================================================
/// API CONFIGURATION
/// =============================================================
/// 
/// Este archivo centraliza la configuración base de la conexión
/// entre el frontend (Flutter) y el backend (API en C#).
///
/// Su propósito principal es definir la URL base de la API
/// que usarán todos los servicios HTTP del proyecto.
///
/// Si el backend cambia de dirección, IP o puerto,
/// solo se debe modificar aquí, y los demás servicios
/// se actualizan automáticamente.
///
/// =============================================================
class ApiConfig {
  static const String baseUrl = 'http://192.168.0.10:5192';
}
