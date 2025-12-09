import 'package:flutter/material.dart';
import 'package:frontend/models/airport_model.dart';
import 'package:frontend/services/airport_service.dart';
import 'edit_airport_screen.dart';

/// Pantalla de detalle de aeropuerto (solo para Admin o CompanyAdmin)
class AirportDetailScreen extends StatefulWidget {
  final int airportId;

  const AirportDetailScreen({super.key, required this.airportId});

  @override
  State<AirportDetailScreen> createState() => _AirportDetailScreenState();
}

class _AirportDetailScreenState extends State<AirportDetailScreen> {
  final AirportService _airportService = AirportService();
  late Future<Airport> _airportFuture;

  @override
  void initState() {
    super.initState();
    _airportFuture = _airportService.getAirportById(widget.airportId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Airport>(
      future: _airportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Airport Details')),
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Airport not found.')),
          );
        }

        final airport = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(airport.name),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, true),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit airport',
                onPressed: () async {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditAirportScreen(airport: airport),
                    ),
                  );

                  if (refresh == true && mounted) {
                    setState(() {
                      _airportFuture = _airportService.getAirportById(
                        widget.airportId,
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
                // Imagen del aeropuerto
                if (airport.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        airport.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // Información general
                _buildSectionTitle('General Information'),
                _buildDetailRow('Name', airport.name),
                _buildDetailRow('Code IATA', airport.codeIATA),
                _buildDetailRow('Code OACI', airport.codeOACI),
                _buildDetailRow('City', airport.city),
                _buildDetailRow('Country', airport.country),
                const SizedBox(height: 20),

                // Ubicación y zona horaria
                _buildSectionTitle('Location & Time Zone'),
                _buildDetailRow('Latitude', '${airport.latitude}'),
                _buildDetailRow('Longitude', '${airport.longitude}'),
                _buildDetailRow('Time Zone', airport.timeZone),
                const SizedBox(height: 20),

                // Horarios
                _buildSectionTitle('Operating Hours'),
                _buildDetailRow('Opening Time', airport.openingTime ?? '—'),
                _buildDetailRow('Closing Time', airport.closingTime ?? '—'),
                const SizedBox(height: 20),

                // Márgenes operativos
                _buildSectionTitle('Operational Margins'),
                _buildDetailRow(
                  'Departure Margin',
                  '${airport.departureMarginMinutes} min',
                ),
                _buildDetailRow(
                  'Arrival Margin',
                  '${airport.arrivalMarginMinutes} min',
                ),
                const SizedBox(height: 20),

                // Configuración técnica
                _buildSectionTitle('Technical Details'),
                _buildDetailRow(
                  'Max Allowed Weight',
                  '${airport.maxAllowedWeight ?? 0} kg',
                ),
                const SizedBox(height: 20),

                // Estado del aeropuerto
                _buildSectionTitle('Status'),
                _buildDetailRow(
                  'Active',
                  airport.isActive ? 'Yes' : 'No',
                  color: airport.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 24),

                // Botón activar/desactivar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          airport.isActive ? Colors.redAccent : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      airport.isActive ? Icons.delete_forever : Icons.restart_alt,
                      color: Colors.white,
                    ),
                    label: Text(
                      airport.isActive
                          ? 'Deactivate Airport'
                          : 'Reactivate Airport',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                            airport.isActive
                                ? 'Deactivate Airport'
                                : 'Reactivate Airport',
                          ),
                          content: Text(
                            airport.isActive
                                ? 'Are you sure you want to deactivate this airport?'
                                : 'Do you want to reactivate this airport?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: airport.isActive
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
                          if (airport.isActive) {
                            await _airportService.deactivateAirport(airport.id);
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('🛑 Airport deactivated')),
                            );
                          } else {
                            await _airportService.reactivateAirport(airport.id);
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('♻️ Airport reactivated')),
                            );
                          }

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

  // Reutilizable para mostrar un campo-valor
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
