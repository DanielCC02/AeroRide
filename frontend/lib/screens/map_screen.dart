import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// MapScreen
/// ---------------------------------------------------------------------------
/// Muestra un Google Map centrado inicialmente en Costa Rica y, al obtener
/// permiso + ubicación, mueve la cámara a la posición actual del usuario.
/// - Botón de “mi ubicación” del mapa habilitado.
/// - Overlay superior con el texto "Buscar en esta área" (mock).
///
/// FUTURO:
/// - Sustituir el overlay por un botón funcional que consulte aeropuertos
///   cercanos en el backend.
/// - Añadir markers de aeropuertos.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // Cámara inicial (Costa Rica aprox.) para que el mapa no arranque vacío.
  static const CameraPosition _kInitial = CameraPosition(
    target: LatLng(9.7489, -83.7534), // CR centro aprox.
    zoom: 6.8,
  );

  // Estado de permisos + ubicación actual.
  bool _hasLocationPermission = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initLocationFlow();
  }

  /// Flujo de permisos + obtención de ubicación.
  /// 1) Verifica servicios de ubicación habilitados.
  /// 2) Solicita permisos si es necesario.
  /// 3) Obtiene la posición actual y anima la cámara.
  Future<void> _initLocationFlow() async {
    // 1) Chequear que el GPS/servicios estén activos
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showSnack('Location services are disabled.');
      return;
    }

    // 2) Verificar/solicitar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      _showSnack('Location permission denied.');
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showSnack('Location permission permanently denied. Enable it in Settings.');
      return;
    }

    setState(() => _hasLocationPermission = true);

    // 3) Obtener posición y mover cámara
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentPosition = pos;

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(pos.latitude, pos.longitude),
          14, // zoom cercano a la ubicación
        ),
      );
    } else {
      // Si el controller aún no está listo, cuando se cree moveremos la cámara.
      // (onMapCreated manejará este caso)
      setState(() {}); // solo para refrescar el estado actual
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // --- Google Map ----------------------------------------------------
          GoogleMap(
            initialCameraPosition: _kInitial,
            myLocationEnabled: _hasLocationPermission,        // punto azul
            myLocationButtonEnabled: true,                    // botón de centrado
            compassEnabled: true,
            zoomControlsEnabled: false,                       // usamos gestos
            onMapCreated: (controller) async {
              _mapController = controller;

              // Si ya tenemos ubicación, centramos la cámara aquí también.
              final pos = _currentPosition;
              if (pos != null) {
                await controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(pos.latitude, pos.longitude),
                    14,
                  ),
                );
              }
            },
          ),

          // --- Overlay superior estilo "Buscar en esta área" ----------------
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: const Text(
                    'Buscar en esta área',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
