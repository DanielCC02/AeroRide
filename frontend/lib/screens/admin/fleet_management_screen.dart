import 'package:flutter/material.dart';
import 'package:frontend/screens/admin/aircraft_detail_screen.dart';
import '../../models/aircraft_model.dart';
import '../../services/aircraft_service.dart';
import '../../services/token_storage.dart';
import '../welcome_screen.dart';
import 'create_aircraft_screen.dart';

class FleetManagementScreen extends StatefulWidget {
  const FleetManagementScreen({super.key});

  @override
  State<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends State<FleetManagementScreen> {
  final AircraftService _aircraftService = AircraftService();
  late Future<List<AircraftModel>> _aircraftsFuture;

  @override
  void initState() {
    super.initState();
    _aircraftsFuture = _aircraftService.getAllAircrafts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Management'),
        automaticallyImplyLeading: true,
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
      body: FutureBuilder<List<AircraftModel>>(
        future: _aircraftsFuture,
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
            return const Center(child: Text('No aircraft found.'));
          }

          final aircrafts = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: aircrafts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final aircraft = aircrafts[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: aircraft.isActive
                      ? Colors.green
                      : Colors.grey,
                  child: const Icon(Icons.flight, color: Colors.white),
                ),
                title: Text(
                  aircraft.model,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${aircraft.patent} • ${aircraft.state}',
                  style: TextStyle(
                    color: aircraft.isActive ? Colors.black87 : Colors.black45,
                  ),
                ),
                trailing: Icon(
                  aircraft.isActive ? Icons.check_circle : Icons.block_flipped,
                  color: aircraft.isActive ? Colors.green : Colors.redAccent,
                ),
                onTap: () async {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AircraftDetailScreen(aircraftId: aircraft.id),
                    ),
                  );

                  // 🔁 Si desde el detalle o edición vuelve con “true”, recargamos la lista
                  if (refresh == true && context.mounted) {
                    setState(() {
                      _aircraftsFuture = _aircraftService.getAllAircrafts();
                    });
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAircraftScreen()),
          );

          // Si la creación fue exitosa, recargamos la lista
          if (refresh == true && mounted) {
            setState(() {
              _aircraftsFuture = _aircraftService.getAllAircrafts();
            });
          }
        },
      ),
    );
  }
}
