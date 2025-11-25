import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/models/flight_log_model.dart';
import 'package:frontend/services/pilot_flight_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewFlightLogScreen extends StatefulWidget {
  final CompanyFlightModel flight;

  const ViewFlightLogScreen({super.key, required this.flight});

  @override
  State<ViewFlightLogScreen> createState() => _ViewFlightLogScreenState();
}

class _ViewFlightLogScreenState extends State<ViewFlightLogScreen> {
  final PilotFlightService _service = PilotFlightService();
  late Future<FlightLogModel?> _logFuture;

  @override
  void initState() {
    super.initState();
    _logFuture = _service.getFlightLogByFlight(widget.flight.id);
  }

  @override
  Widget build(BuildContext context) {
    final routeText =
        '${widget.flight.departureAirportName ?? ''} → ${widget.flight.arrivalAirportName ?? ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Log – $routeText'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final log = await _logFuture;

              if (log == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No log available to download")),
                );
                return;
              }

              // Usa url_launcher para abrir el PDF en el navegador
              if (await canLaunchUrl(Uri.parse(log.pdfUrl))) {
                await launchUrl(
                  Uri.parse(log.pdfUrl),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Unable to open download link")),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<FlightLogModel?>(
        future: _logFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading flight log:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final log = snapshot.data;
          if (log == null) {
            return const Center(
              child: Text(
                'No flight log found for this flight.',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Mostrar el PDF
          return PDF().cachedFromUrl(
            log.pdfUrl,
            placeholder: (progress) =>
                Center(child: Text('Loading PDF... $progress%')),
            errorWidget: (error) =>
                Center(child: Text('Error displaying PDF:\n$error')),
          );
        },
      ),
    );
  }
}
