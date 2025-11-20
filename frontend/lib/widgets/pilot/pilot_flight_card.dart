import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/services/pilot_flight_service.dart';
import 'package:frontend/screens/pilot/view_flight_log_screen.dart';
import 'package:frontend/screens/pilot/flight_log_form_screen.dart';

class PilotFlightCard extends StatefulWidget {
  final CompanyFlightModel flight;
  final bool hasLog; // NUEVO
  final VoidCallback onReload; // Para refrescar HomePagePilot después de cambios

  const PilotFlightCard({
    super.key,
    required this.flight,
    required this.hasLog,
    required this.onReload,
  });

  @override
  State<PilotFlightCard> createState() => _PilotFlightCardState();
}

class _PilotFlightCardState extends State<PilotFlightCard> {
  late String _currentStatus;
  final PilotFlightService _service = PilotFlightService();

  static const List<String> flightStatusOptions = [
    "PreFlight",
    "Boarding",
    "PushbackOrRamp",
    "TaxiToRunway",
    "HoldingShort",
    "Takeoff",
    "EnRoute",
    "Landing",
    "TaxiToRamp",
    "Deboarding",
    "Completed",
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.flight.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    // Regla: NO permitir "Completed" sin bitácora
    if (newStatus == "Completed" && !widget.hasLog) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must submit a flight log before marking as Completed."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await _service.updateFlightStatus(
        flightId: widget.flight.id,
        newStatus: newStatus,
      );

      setState(() => _currentStatus = newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status updated to $newStatus"),
          backgroundColor: Colors.green,
        ),
      );

      widget.onReload();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating status: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d • hh:mm a');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.flight.departureAirportName} → ${widget.flight.arrivalAirportName}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              '${widget.flight.departureAirportOACI ?? ''} → ${widget.flight.arrivalAirportOACI ?? ''}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),

            const SizedBox(height: 10),

            Text(
              '${df.format(widget.flight.departureLocal)}  —  ${df.format(widget.flight.arrivalLocal)}',
              style: TextStyle(color: Colors.grey[700], fontSize: 15),
            ),

            const SizedBox(height: 8),

            Text('Aircraft: ${widget.flight.aircraftModel ?? 'Unknown'}'),
            const SizedBox(height: 8),

            Text(
              'Duration: ${widget.flight.duration.inMinutes} min',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 16),

            // DROPDOWN DE ESTADO (solo si NO está completado)
            if (_currentStatus != "Completed")
              DropdownButtonFormField<String>(
                value: _currentStatus,
                decoration: const InputDecoration(
                  labelText: "Flight Status",
                  border: OutlineInputBorder(),
                ),
                items: flightStatusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateStatus(value);
                  }
                },
              ),

            if (_currentStatus == "Completed")
              Text(
                "Status: Completed",
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 16),

            // Botón dinámico: Fill o View flight log
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: widget.hasLog
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewFlightLogScreen(
                              flight: widget.flight,
                            ),
                          ),
                        );
                      }
                    : () async {
                        final refreshed = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FlightLogFormScreen(flight: widget.flight),
                          ),
                        );

                        if (refreshed == true && mounted) widget.onReload();
                      },
                icon: Icon(widget.hasLog
                    ? Icons.picture_as_pdf
                    : Icons.assignment),
                label: Text(widget.hasLog
                    ? "View flight log"
                    : "Fill flight log"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.hasLog ? Colors.blueGrey : Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
