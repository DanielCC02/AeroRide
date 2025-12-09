import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/airport_service.dart';
import '../models/airport_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // Cámara inicial (Costa Rica)
  static const CameraPosition _kInitial = CameraPosition(
    target: LatLng(9.7489, -83.7534),
    zoom: 6.8,
  );

  bool _hasLocationPermission = false;
  Position? _currentPosition;

  late final AirportService _airportService;

  Set<Marker> _markers = {};
  final List<Airport> _airports = []; // lista completa para búsqueda local
  final TextEditingController _searchController = TextEditingController();

  List<Airport> _searchResults = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _airportService = AirportService();
    _initLocationFlow();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // PERMISOS + UBICACIÓN
  // ─────────────────────────────────────────────────────────────
  Future<void> _initLocationFlow() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showSnack('Location services are disabled.');
      return;
    }

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
      _showSnack('Location permission permanently denied.');
      return;
    }

    setState(() => _hasLocationPermission = true);

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentPosition = pos;

    // Si el mapController ya existe, centramos de una vez
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(pos.latitude, pos.longitude),
          14,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // CARGA DE AEROPUERTOS + MARKERS (una vez)
  // ─────────────────────────────────────────────────────────────
  Future<void> _loadAirportsMarkers() async {
    try {
      final airports = await _airportService.getActiveAirports();

      if (!mounted) return;

      _airports
        ..clear()
        ..addAll(airports);

      final newMarkers = airports.map((a) {
        return Marker(
          markerId: MarkerId('airport_${a.id}'),
          position: LatLng(a.latitude, a.longitude),
          infoWindow: InfoWindow(
            title: '${a.name} (${a.codeIATA})',
            snippet: '${a.city}, ${a.country}',
          ),
        );
      }).toSet();

      setState(() {
        _markers = newMarkers;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error cargando aeropuertos: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BÚSQUEDA LOCAL (SIN LLAMAR AL BACKEND)
  // ─────────────────────────────────────────────────────────────
  void _searchAirport(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _showResults = false;
        _searchResults.clear();
      });
      return;
    }

    final results = _airports.where((a) {
      return a.name.toLowerCase().contains(q) ||
          a.codeIATA.toLowerCase().contains(q) ||
          a.city.toLowerCase().contains(q) ||
          a.country.toLowerCase().contains(q);
    }).toList();

    setState(() {
      _showResults = results.isNotEmpty;
      _searchResults = results;
    });
  }

  Future<void> _focusAirport(Airport airport) async {
    _searchController.clear();
    setState(() => _showResults = false);

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(airport.latitude, airport.longitude),
        14,
      ),
    );

    _showSnack('📍 ${airport.name}');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map'), centerTitle: true),
      body: Stack(
        children: [
          // Mapa ocupando toda la pantalla
          Positioned.fill(
            child: RepaintBoundary(
              child: GoogleMap(
                initialCameraPosition: _kInitial,
                myLocationEnabled: _hasLocationPermission,
                myLocationButtonEnabled: true,
                compassEnabled: true,
                zoomControlsEnabled: false,
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;

                  // Diferimos la carga pesada para no pelear con la init de Google Maps
                  Future.microtask(() async {
                    await _loadAirportsMarkers();

                    // Si ya tenemos ubicación, centramos
                    final pos = _currentPosition;
                    if (pos != null) {
                      await _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(pos.latitude, pos.longitude),
                          14,
                        ),
                      );
                    }
                  });
                },
              ),
            ),
          ),

          // 🔍 Barra de búsqueda + resultados
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Container(
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
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar aeropuerto...',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _showResults
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _showResults = false);
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: _searchAirport,
                    ),
                  ),
                  if (_showResults)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, i) {
                          final a = _searchResults[i];
                          return ListTile(
                            leading: const Icon(Icons.flight_takeoff),
                            title: Text('${a.name} (${a.codeIATA})'),
                            subtitle: Text('${a.city}, ${a.country}'),
                            onTap: () => _focusAirport(a),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
