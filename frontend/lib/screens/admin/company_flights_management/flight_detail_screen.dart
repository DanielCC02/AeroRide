import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/company_id_provider.dart';
import 'package:frontend/services/user_service.dart';
import 'package:provider/provider.dart';

/// Pantalla de detalles de un vuelo específico.
class FlightDetailScreen extends StatefulWidget {
  final CompanyFlightModel flight;

  const FlightDetailScreen({super.key, required this.flight});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _pilotsFuture;

  UserModel? _selectedPilot;
  UserModel? _selectedCopilot;

  @override
  void initState() {
    super.initState();
    final companyId =
        Provider.of<CompanyIdProvider>(context, listen: false).companyId;
    if (companyId != null) {
      _pilotsFuture = _userService.getPilotsByCompany(companyId);
    } else {
      _pilotsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dfDateTime = DateFormat('MMM d, yyyy • hh:mm a');
    final flight = widget.flight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Details'),
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
              child: Text(
                '⚠️ Error loading pilots:\n${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final pilots = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ruta
                Center(
                  child: Text(
                    '${flight.departureAirportName ?? 'Unknown'} → ${flight.arrivalAirportName ?? 'Unknown'}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),

                // Horarios
                _buildSectionTitle(context, 'Schedule'),
                _buildRow('Departure',
                    dfDateTime.format(flight.departureTime.toLocal())),
                _buildRow(
                    'Arrival', dfDateTime.format(flight.arrivalTime.toLocal())),
                _buildRow('Duration',
                    '${flight.durationMinutes.toStringAsFixed(1)} minutes'),

                const SizedBox(height: 20),

                // Aeronave
                _buildSectionTitle(context, 'Aircraft'),
                _buildRow('Model', flight.aircraftModel ?? 'N/A'),
                _buildRow('Patent', flight.aircraftPatent ?? 'N/A'),

                const SizedBox(height: 20),

                // Compañía
                _buildSectionTitle(context, 'Company'),
                _buildRow('Name', flight.companyName ?? 'N/A'),
                _buildRow('Reservation Code', flight.reservationCode ?? 'N/A'),

                const SizedBox(height: 20),

                // Estado
                _buildSectionTitle(context, 'Status'),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: flight.status == 'Programado'
                        ? Colors.green.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    flight.status,
                    style: TextStyle(
                      color: flight.status == 'Programado'
                          ? Colors.green[700]
                          : Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 👩‍✈️ ASIGNAR PILOTOS
                _buildSectionTitle(context, 'Assign Pilots'),

                DropdownButtonFormField<UserModel>(
                  decoration: const InputDecoration(
                    labelText: 'Select Pilot',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedPilot,
                  items: pilots
                      .map(
                        (p) => DropdownMenuItem<UserModel>(
                          value: p,
                          child: Text('${p.name} ${p.lastName}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPilot = value;
                    });
                  },
                  validator: (v) =>
                      v == null ? 'Please select a pilot' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<UserModel>(
                  decoration: const InputDecoration(
                    labelText: 'Select Copilot (optional)',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCopilot,
                  items: pilots
                      .map(
                        (p) => DropdownMenuItem<UserModel>(
                          value: p,
                          child: Text('${p.name} ${p.lastName}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCopilot = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // BOTÓN TEMPORAL (solo simula la asignación)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('Assign Flight'),
                    onPressed: () {
                      final pilotName = _selectedPilot != null
                          ? '${_selectedPilot!.name} ${_selectedPilot!.lastName}'
                          : 'none';
                      final copilotName = _selectedCopilot != null
                          ? '${_selectedCopilot!.name} ${_selectedCopilot!.lastName}'
                          : 'none';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ Flight assigned to: $pilotName\nCopilot: $copilotName',
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.redAccent),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
