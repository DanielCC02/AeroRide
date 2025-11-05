import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/company_id_provider.dart';
import 'package:frontend/screens/admin/company_pilots/pilot_detail_screen.dart';
import 'package:frontend/services/user_service.dart';
import 'package:provider/provider.dart';
import 'create_pilot_screen.dart';

class CompanyPilotsScreen extends StatefulWidget {
  const CompanyPilotsScreen({super.key});

  @override
  State<CompanyPilotsScreen> createState() => _CompanyPilotsScreenState();
}

class _CompanyPilotsScreenState extends State<CompanyPilotsScreen> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _pilotsFuture;

  @override
  void initState() {
    super.initState();
    // Acceder al companyId desde el provider
    final companyId = Provider.of<CompanyIdProvider>(
      context,
      listen: false,
    ).companyId;

    // Agregar un print para verificar el companyId que estamos recibiendo
    print('CompanyPilotsScreen - companyId: $companyId');

    if (companyId != null) {
      _pilotsFuture = _userService.getPilotsByCompany(
        companyId,
      ); // Usamos el companyId del provider
    } else {
      _pilotsFuture = Future.value(
        [],
      ); // Si no hay companyId, mostramos una lista vacía
    }
  }

  Future<void> _refreshPilots() async {
    final companyId = Provider.of<CompanyIdProvider>(
      context,
      listen: false,
    ).companyId;

    // Agregar un print para verificar el companyId en el refresh
    print('CompanyPilotsScreen - Refresh - companyId: $companyId');

    if (companyId != null) {
      setState(() {
        _pilotsFuture = _userService.getPilotsByCompany(
          companyId,
        ); // Refrescar la lista de pilotos
      });
    }
  }

  Future<void> _goToCreatePilot() async {
    final companyId = Provider.of<CompanyIdProvider>(
      context,
      listen: false,
    ).companyId;

    // Agregar un print para verificar el companyId antes de crear un piloto
    print('CompanyPilotsScreen - Go to Create Pilot - companyId: $companyId');

    if (companyId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CreatePilotScreen(), // Pasamos el companyId al crear el piloto
        ),
      );
      await _refreshPilots(); // Refrescar la lista de pilotos al volver
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilots of the Company'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _pilotsFuture,
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
                    '⚠️ Error loading pilots:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshPilots,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final pilots = snapshot.data ?? [];

          if (pilots.isEmpty) {
            return const Center(
              child: Text('No pilots found for this company.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshPilots,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pilots.length,
              itemBuilder: (context, index) {
                final pilot = pilots[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.shade100,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('${pilot.name} ${pilot.lastName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pilot.email),
                        Text(pilot.phoneNumber),
                        Text(
                          pilot.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: pilot.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PilotDetailScreen(userId: pilot.id),
                        ),
                      );

                      // ✅ Si desde el detalle o edición se devolvió "true", refrescamos la lista
                      if (refresh == true && context.mounted) {
                        print(
                          '🔁 Refrescando lista de pilotos tras edición...',
                        );
                        await _refreshPilots();
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
        onPressed:
            _goToCreatePilot, // Navegar a la pantalla de creación de piloto
        icon: const Icon(Icons.add),
        label: const Text('Create Pilot'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
