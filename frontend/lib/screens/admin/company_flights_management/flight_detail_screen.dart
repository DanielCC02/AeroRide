import 'package:flutter/material.dart';
import 'package:frontend/screens/admin/company_flights_management/admin_view_flight_log_screen.dart';
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

    // ==============================
    // 🔥 NUEVAS REGLAS
    // ==============================
    const assignableStates = ["PreFlight", "Boarding"];
    const lockedStates = [
      "PushbackOrRamp",
      "TaxiToRunway",
      "HoldingShort",
      "Takeoff",
      "EnRoute",
      "Landing",
      "TaxiToRamp",
      "Deboarding",
    ];

    final bool isCompleted = flight.status == "Completed";
    final bool canEditAssignments = assignableStates.contains(flight.status);
    final bool isLockedMidFlight = lockedStates.contains(flight.status);

    final bool canViewLog = isCompleted; // solo cuando está completado

    return Scaffold(
      appBar: AppBar(title: const Text('Flight Details'), centerTitle: true),
      body: FutureBuilder(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

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
                // ===========================================
                // FLIGHT DATA
                // ===========================================
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

                _buildSectionTitle(context, 'Aircraft'),
                _buildRow('Model', flight.aircraftModel ?? 'N/A'),
                _buildRow('Patent', flight.aircraftPatent ?? 'N/A'),

                const SizedBox(height: 20),

                _buildSectionTitle(context, 'Company'),
                _buildRow('Name', flight.companyName ?? 'N/A'),
                _buildRow('Reservation Code', flight.reservationCode ?? 'N/A'),

                const SizedBox(height: 20),

                _buildSectionTitle(context, 'Status'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    flight.status,
                    style: TextStyle(
                      color: isCompleted
                          ? Colors.green[700]
                          : Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ===========================================
                // CREW SECTION
                // ===========================================
                _buildSectionTitle(
                  context,
                  canEditAssignments ? 'Assign Pilots' : 'Assigned Crew',
                ),

                // Pilot selector
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
                  onChanged: (canEditAssignments)
                      ? (value) {
                          setState(() {
                            if (_selectedCopilot?.id == value?.id) {
                              _selectedCopilot = null;
                            }
                            _selectedPilot = value;
                          });
                        }
                      : null,
                ),

                const SizedBox(height: 16),

                // Copilot selector
                DropdownButtonFormField<UserModel>(
                  decoration: const InputDecoration(
                    labelText: "Copilot (optional)",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCopilot,
                  items: [
                    const DropdownMenuItem<UserModel>(
                      value: null,
                      child: Text("— None —"),
                    ),
                    ...copilotOptions.map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text("${p.name} ${p.lastName}"),
                      ),
                    ),
                  ],
                  onChanged: (canEditAssignments)
                      ? (value) {
                          setState(() {
                            if (value == null) {
                              _selectedCopilot = null;
                              return;
                            }

                            if (_selectedPilot?.id == value.id) {
                              _selectedPilot = null;
                            }

                            _selectedCopilot = value;
                          });
                        }
                      : null,
                ),

                const SizedBox(height: 24),

                // ===========================================
                // BOTTOM BUTTON AREA
                // ===========================================

                // ⛔ Locked mid-flight → NO button
                if (isLockedMidFlight)
                  const SizedBox.shrink()
                // ✔ Completed → show View Log
                else if (canViewLog)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("View flight log"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminViewFlightLogScreen(flight: flight),
                          ),
                        );
                      },
                    ),
                  )
                // ✔ Can assign pilots
                else if (canEditAssignments)
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
