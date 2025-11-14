import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/flight_assigned_pilot_model.dart';
import 'package:frontend/services/company_flight_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/providers/company_id_provider.dart';
import 'package:provider/provider.dart';

class FlightDetailScreen extends StatefulWidget {
  final CompanyFlightModel flight;

  const FlightDetailScreen({super.key, required this.flight});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  final UserService _userService = UserService();
  final CompanyFlightService _flightService = CompanyFlightService();

  late Future<void> _initialLoad;

  List<UserModel> _pilots = [];
  UserModel? _selectedPilot;
  UserModel? _selectedCopilot;

  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadData();
  }

  /// Buscar un piloto por ID dentro de la lista
  UserModel? _findPilot(int pilotId) {
    try {
      return _pilots.firstWhere((p) => p.id == pilotId);
    } catch (_) {
      return null;
    }
  }

  /// Cargar pilotos de la empresa + asignados al vuelo
  Future<void> _loadData() async {
    final companyId = Provider.of<CompanyIdProvider>(
      context,
      listen: false,
    ).companyId;
    if (companyId == null) return;

    // 1) Obtener todos los pilotos de la empresa
    _pilots = await _userService.getPilotsByCompany(companyId);

    // 2) Obtener asignaciones del backend
    List<FlightAssignedPilotModel> assigned = await _userService
        .getAssignedPilotsByFlight(widget.flight.id);

    // 3) Asignar según el rol (Pilot / CoPilot)
    for (var a in assigned) {
      if (a.crewRole == "Pilot") {
        _selectedPilot = _findPilot(a.pilotId);
      } else if (a.crewRole == "CoPilot") {
        _selectedCopilot = _findPilot(a.pilotId);
      }
    }

    if (mounted) setState(() {});
  }

  /// Asignar pilotos al vuelo usando el backend real
  Future<void> _assignFlight() async {
  if (_selectedPilot == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a pilot."),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  setState(() => _isAssigning = true);

  try {
    await _flightService.assignPilotsToFlight(
      flightId: widget.flight.id,
      pilotId: _selectedPilot!.id,
      coPilotId: _selectedCopilot?.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Flight assigned successfully."),
        backgroundColor: Colors.green,
      ),
    );

    // AVISAR AL CALLER QUE HUBO CAMBIOS
    Navigator.pop(context, true);
    return;

  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ Error assigning flight:\n$e"),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    if (mounted) setState(() => _isAssigning = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d, yyyy • hh:mm a');
    final flight = widget.flight;

    return Scaffold(
      appBar: AppBar(title: const Text('Flight Details'), centerTitle: true),
      body: FutureBuilder(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// Filtrar pilotos para evitar duplicados entre pilot y copilot
          final pilotOptions = _pilots
              .where((p) => p.id != _selectedCopilot?.id)
              .toList();
          final copilotOptions = _pilots
              .where((p) => p.id != _selectedPilot?.id)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ruta
                Center(
                  child: Text(
                    '${flight.departureAirportName} → ${flight.arrivalAirportName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Horarios
                _buildSectionTitle(context, 'Schedule'),
                _buildRow(
                  'Departure',
                  df.format(flight.departureTime.toLocal()),
                ),
                _buildRow('Arrival', df.format(flight.arrivalTime.toLocal())),
                _buildRow(
                  'Duration',
                  '${flight.durationMinutes.toStringAsFixed(1)} minutes',
                ),

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
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
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

                // ASIGNACIÓN DE PILOTOS
                _buildSectionTitle(context, 'Assign Pilots'),

                // PILOTO PRINCIPAL
                DropdownButtonFormField<UserModel>(
                  decoration: const InputDecoration(
                    labelText: "Pilot",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedPilot,
                  items: pilotOptions
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text("${p.name} ${p.lastName}"),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      if (_selectedCopilot?.id == value?.id) {
                        _selectedCopilot = null; // limpiar copiloto si coincide
                      }
                      _selectedPilot = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // COPILOTO
                DropdownButtonFormField<UserModel>(
                  decoration: const InputDecoration(
                    labelText: "Copilot (optional)",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCopilot,
                  items: [
                    // 👉 Opción vacía (para remover copiloto)
                    const DropdownMenuItem<UserModel>(
                      value: null,
                      child: Text("— None —"),
                    ),

                    // 👉 Opciones filtradas de copilotos disponibles
                    ...copilotOptions.map(
                      (p) => DropdownMenuItem<UserModel>(
                        value: p,
                        child: Text("${p.name} ${p.lastName}"),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      // Si eligen "None", value == null
                      if (value == null) {
                        _selectedCopilot = null;
                        return;
                      }

                      // Evitar duplicado piloto/copiloto
                      if (_selectedPilot?.id == value.id) {
                        _selectedPilot = null;
                      }

                      _selectedCopilot = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // BOTÓN DE ASIGNACIÓN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isAssigning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.assignment),
                    label: Text(
                      _isAssigning ? "Assigning..." : "Assign Flight",
                    ),
                    onPressed: _isAssigning ? null : _assignFlight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helpers UI
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
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
