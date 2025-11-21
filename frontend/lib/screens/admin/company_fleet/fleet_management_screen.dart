import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/aircraft_model.dart';
import 'package:frontend/providers/company_id_provider.dart';
import 'package:frontend/services/aircraft_service.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/screens/admin/company_fleet/aircraft_detail_screen.dart';
import 'package:frontend/screens/admin/company_fleet/create_aircraft_screen.dart';

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
    final companyId = Provider.of<CompanyIdProvider>(context, listen: false).companyId;

    // Debug print
    debugPrint('FleetManagementScreen - companyId: $companyId');

    if (companyId != null) {
      _aircraftsFuture = _aircraftService.getAircraftsByCompany(companyId);
    } else {
      _aircraftsFuture = Future.value([]);
    }
  }

  Future<void> _refreshAircrafts() async {
    final companyId = Provider.of<CompanyIdProvider>(context, listen: false).companyId;

    // Debug print
    debugPrint('FleetManagementScreen - Refresh - companyId: $companyId');

    if (companyId != null) {
      setState(() {
        _aircraftsFuture = _aircraftService.getAircraftsByCompany(companyId);
      });
    }
  }

  Future<void> _goToCreateAircraft() async {
    final companyId = Provider.of<CompanyIdProvider>(context, listen: false).companyId;

    // Debug print
    debugPrint('FleetManagementScreen - Go to Create Aircraft - companyId: $companyId');

    if (companyId != null) {
      final refresh = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateAircraftScreen()),
      );

      if (refresh == true && mounted) {
        await _refreshAircrafts();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el companyId')),
      );
    }
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
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '⚠️ Error loading aircrafts:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshAircrafts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final aircrafts = snapshot.data ?? [];

          if (aircrafts.isEmpty) {
            return const Center(
              child: Text('No aircraft found for this company.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAircrafts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: aircrafts.length,
              itemBuilder: (context, index) {
                final aircraft = aircrafts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          aircraft.isActive ? Colors.green : Colors.grey,
                      child: const Icon(Icons.flight, color: Colors.white),
                    ),
                    title: Text(
                      aircraft.model,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${aircraft.patent} • ${aircraft.state}',
                      style: TextStyle(
                        color:
                            aircraft.isActive ? Colors.black87 : Colors.black45,
                      ),
                    ),
                    trailing: Icon(
                      aircraft.isActive
                          ? Icons.check_circle
                          : Icons.block_flipped,
                      color: aircraft.isActive ? Colors.green : Colors.redAccent,
                    ),
                    onTap: () async {
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AircraftDetailScreen(aircraftId: aircraft.id),
                        ),
                      );

                      if (refresh == true && context.mounted) {
                        await _refreshAircrafts();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCreateAircraft,
        icon: const Icon(Icons.add),
        label: const Text('Create Aircraft'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
