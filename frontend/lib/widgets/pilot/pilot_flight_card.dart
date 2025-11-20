import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/company_flight_model.dart';

class PilotFlightCard extends StatelessWidget {
  final CompanyFlightModel flight;
  final VoidCallback onDetails;

  const PilotFlightCard({
    super.key,
    required this.flight,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d • hh:mm a');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onDetails,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ruta principal con nombres
              Text(
                '${flight.departureAirportName} → ${flight.arrivalAirportName}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Codigos OACI
              Text(
                '${flight.departureAirportOACI ?? ''} → ${flight.arrivalAirportOACI ?? ''}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),

              const SizedBox(height: 10),

              // Horario
              Text(
                '${df.format(flight.departureLocal)}  —  ${df.format(flight.arrivalLocal)}',
                style: TextStyle(color: Colors.grey[700], fontSize: 15),
              ),

              const SizedBox(height: 8),

              // Aeronave
              Text(
                'Aircraft: ${flight.aircraftModel ?? 'Unknown'}',
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 8),

              // Duración estimada
              Text(
                'Duration: ${flight.duration.inMinutes} min',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              // Estado
              Text(
                'Status: ${flight.status}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: flight.status == "Programado"
                      ? Colors.green
                      : Colors.orange,
                ),
              ),

              const SizedBox(height: 14),

              // ===== BOTÓN PARA LLENAR BITÁCORA
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.assignment),
                  label: const Text("Fill flight log"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
