import 'package:flutter/material.dart';
import 'package:frontend/screens/admin/company_fleet/edit_aircraft_screen.dart';
import '../../../models/aircraft_model.dart';
import '../../../services/aircraft_service.dart';

/// Pantalla que muestra la información detallada de una aeronave.
/// Accesible para el administrador desde el Fleet Management.
class AircraftDetailScreen extends StatefulWidget {
  final int aircraftId;

  const AircraftDetailScreen({super.key, required this.aircraftId});

  @override
  State<AircraftDetailScreen> createState() => _AircraftDetailScreenState();
}

class _AircraftDetailScreenState extends State<AircraftDetailScreen> {
  final AircraftService _aircraftService = AircraftService();
  late Future<AircraftModel?> _aircraftFuture;

  @override
  void initState() {
    super.initState();
    _aircraftFuture = _aircraftService.getAircraftById(widget.aircraftId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AircraftModel?>(
      future: _aircraftFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final aircraft = snapshot.data;
        if (aircraft == null) {
          return const Center(child: Text('Aircraft not found'));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(aircraft.model),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditAircraftScreen(aircraft: aircraft),
                    ),
                  );

                  if (refresh == true && context.mounted) {
                    setState(() {
                      _aircraftFuture = _aircraftService.getAircraftById(
                        widget.aircraftId,
                      );
                    });
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen
                if (aircraft.image.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          aircraft.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // Datos generales
                _buildSectionTitle('General Information'),
                _buildDetailRow('Patent', aircraft.patent),
                _buildDetailRow('Model', aircraft.model),
                _buildDetailRow(
                  'Minute Cost',
                  '\$${aircraft.minuteCost.toStringAsFixed(2)}',
                ),
                _buildDetailRow('Seats', '${aircraft.seats}'),
                _buildDetailRow('Empty Weight', '${aircraft.emptyWeight} kg'),
                _buildDetailRow('Max Weight', '${aircraft.maxWeight} kg'),
                _buildDetailRow(
                  'Cruising Speed',
                  '${aircraft.cruisingSpeed} km/h',
                ),
                _buildDetailRow(
                  'Can Fly International',
                  aircraft.canFlyInternational ? 'Yes' : 'No',
                ),
                const SizedBox(height: 20),

                // Ubicación (con nombres)
                _buildSectionTitle('Base & Current Airport'),
                _buildDetailRow('Base Airport', aircraft.baseAirportName),
                _buildDetailRow(
                  'Current Airport',
                  aircraft.currentAirportName ?? '—',
                ),
                const SizedBox(height: 20),

                // Estado y compañía
                _buildSectionTitle('Status & Ownership'),
                _buildDetailRow(
                  'State',
                  aircraft.state,
                  color: Colors.blueGrey,
                ),
                _buildDetailRow(
                  'Status',
                  aircraft.isActive ? 'Active' : 'Inactive',
                  color: aircraft.isActive ? Colors.green : Colors.red,
                ),
                _buildDetailRow('Company', aircraft.companyName),
                const SizedBox(height: 30),

                // Botón activar/desactivar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          aircraft.isActive ? Colors.redAccent : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      aircraft.isActive
                          ? Icons.delete_forever
                          : Icons.restart_alt,
                      color: Colors.white,
                    ),
                    label: Text(
                      aircraft.isActive
                          ? 'Deactivate Aircraft'
                          : 'Reactivate Aircraft',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () async {
                      // Guardamos referencias antes del await
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      // Antes de pedir confirmación → validar vuelos futuros
                      if (aircraft.isActive) {
                        final hasFutureFlights = await _aircraftService
                            .hasFutureFlights(aircraft.id);

                        if (hasFutureFlights) {
                          if (!mounted) return;

                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Action not allowed"),
                              content: const Text(
                                "This aircraft is assigned to future scheduled flights.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );

                          return; // No permitir desactivación
                        }
                      }

                      // Si llegó aquí → pedir confirmación normal
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                            aircraft.isActive
                                ? 'Deactivate Aircraft'
                                : 'Reactivate Aircraft',
                          ),
                          content: Text(
                            aircraft.isActive
                                ? 'Are you sure you want to deactivate this aircraft?'
                                : 'Do you want to reactivate this aircraft?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: aircraft.isActive
                                    ? Colors.redAccent
                                    : Colors.green,
                              ),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          if (aircraft.isActive) {
                            await _aircraftService.deactivateAircraft(
                              aircraft.id,
                            );
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('🛑 Aircraft deactivated'),
                              ),
                            );
                          } else {
                            await _aircraftService.reactivateAircraft(
                              aircraft.id,
                            );
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('♻️ Aircraft reactivated'),
                              ),
                            );
                          }

                          if (!mounted) return;
                          navigator.pop(true);
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('⚠️ Error: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Subtítulo de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Reutilizable: campo-valor
  Widget _buildDetailRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: color ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
