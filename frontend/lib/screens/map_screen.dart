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

  static const CameraPosition _kInitial = CameraPosition(
    target: LatLng(9.7489, -83.7534), // CR
    zoom: 6.8,
  );

  bool _hasLocationPermission = false;
  Position? _currentPosition;

  final Set<Marker> _markers = {};
  final List<Airport> _airports = []; // lista completa para los marcadores
  final TextEditingController _searchController = TextEditingController();

  List<Airport> _searchResults = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _initLocationFlow();
  }

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
  }

  Future<void> _loadAirportsMarkers() async {
    try {
      // Traemos “muchos” para poblar el mapa (si tu API pagina, aquí puedes iterar).
      final airports = await AirportService.searchAirports('', limit: 400);

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

      if (!mounted) return;
      setState(() {
        _markers
          ..clear()
          ..addAll(newMarkers);
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error cargando aeropuertos: $e');
    }
  }

  Future<void> _searchAirport(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _showResults = false;
        _searchResults.clear();
      });
      return;
    }

    // Búsqueda dinámica al backend (en vez de filtrar local).
    final results = await AirportService.searchAirports(q, limit: 8);

    if (!mounted) return;
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map'), centerTitle: true),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kInitial,
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers,
            onMapCreated: (controller) async {
              _mapController = controller;
              await _loadAirportsMarkers();

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

          // --- 🔍 Barra de búsqueda ------------------------------------------
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
