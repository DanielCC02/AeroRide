import 'package:flutter/material.dart';
import 'package:frontend/screens/admin/edit_aircraft_screen.dart';
import '../../models/aircraft_model.dart';
import '../../services/aircraft_service.dart';

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
  late Future<AircraftModel> _aircraftFuture;

  @override
  void initState() {
    super.initState();
    _aircraftFuture = _aircraftService.getAircraftById(widget.aircraftId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AircraftModel>(
      future: _aircraftFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Aircraft Details')),
            body: Center(
              child: Text(
                '⚠️ Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Aircraft not found.')),
          );
        }

        final aircraft = snapshot.data!;

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
                    Navigator.pop(
                      context,
                      true,
                    ); // 👈 Devuelve “true” al FleetManagementScreen
                  }
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
                // Imagen de la aeronave (más ancha, con padding horizontal reducido)
                if (aircraft.image.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ), // margen lateral más pequeño
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio:
                            16 / 9, // mantiene proporción visual moderna
                        child: Image.network(
                          aircraft.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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

                _buildDetailRow('Patent', aircraft.patent),
                _buildDetailRow('Model', aircraft.model),
                _buildDetailRow(
                  'Price',
                  '\$${aircraft.price.toStringAsFixed(2)}',
                ),
                _buildDetailRow('Seats', '${aircraft.seats}'),
                _buildDetailRow('Max Weight', '${aircraft.maxWeight} kg'),
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
                const SizedBox(height: 30),

                // 🔹 Botón para activar/desactivar aeronave
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: aircraft.isActive
                          ? Colors.redAccent
                          : Colors.green, // cambia color
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      aircraft.isActive ? Icons.delete_forever : Icons.restart_alt,
                      color: Colors.white,
                    ),
                    label: Text(
                      aircraft.isActive
                          ? 'Deactivate Aircraft'
                          : 'Reactivate Aircraft',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
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
                            await _aircraftService.deactivateAircraft(aircraft.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '🛑 Aircraft deactivated successfully',
                                ),
                              ),
                            );
                          } else {
                            await _aircraftService.reactivateAircraft(aircraft.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '♻️ Aircraft reactivated successfully',
                                ),
                              ),
                            );
                          }

                          // 🔁 Devolver true para que FleetManagementScreen recargue
                          if (context.mounted) Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
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

  /// 🔹 Reutilizable: muestra una fila tipo "campo: valor"
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
