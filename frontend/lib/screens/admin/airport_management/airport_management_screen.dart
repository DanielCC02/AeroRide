import 'package:flutter/material.dart';
import 'package:frontend/models/airport_model.dart';
import 'package:frontend/screens/admin/airport_management/airport_detail_screen.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/services/airport_service.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:frontend/screens/admin/airport_management/create_airport_screen.dart';

/// Pantalla principal para la gestión de aeropuertos.
/// Similar a la CompanyManagementScreen, pero enfocada en aeropuertos.
class AirportManagementScreen extends StatefulWidget {
  const AirportManagementScreen({super.key});

  @override
  State<AirportManagementScreen> createState() =>
      _AirportManagementScreenState();
}

class _AirportManagementScreenState extends State<AirportManagementScreen> {
  final AirportService _airportService = AirportService();
  late Future<List<Airport>> _airportsFuture;

  @override
  void initState() {
    super.initState();
    _airportsFuture = _airportService.getAllAirports();
  }

  // 🔁 Refrescar lista tras crear aeropuerto
  void _refreshAirports() {
    setState(() {
      _airportsFuture = _airportService.getAllAirports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Airport Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await TokenStorage.clearTokens();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Airport>>(
        future: _airportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '⚠️ Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No airports found.'));
          }

          final airports = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: airports.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final airport = airports[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: airport.isActive
                      ? Colors.green
                      : Colors.grey,
                  child: Text(
                    airport.codeIATA.isNotEmpty
                        ? airport.codeIATA[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(airport.name),
                subtitle: Text(
                  '${airport.city}, ${airport.country} • ${airport.codeIATA}',
                ),
                trailing: Icon(
                  airport.isActive ? Icons.check_circle : Icons.block,
                  color: airport.isActive ? Colors.green : Colors.red,
                ),
                onTap: () async {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AirportDetailScreen(airportId: airport.id),
                    ),
                  );

                  // 🔁 Si el aeropuerto fue editado o desactivado, refrescar lista
                  if (refresh == true && context.mounted) {
                    _refreshAirports();
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        tooltip: 'Agregar Aeropuerto',
        child: const Icon(Icons.add_location_alt),
        onPressed: () async {
          // 🛫 Navegar a CreateAirportScreen
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAirportScreen()),
          );

          // 🔁 Si se creó uno nuevo, refrescar lista
          if (refresh == true && mounted) {
            _refreshAirports();
          }
        },
      ),
    );
  }
}
