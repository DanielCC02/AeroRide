import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/models/flight_log_model.dart';
import 'package:frontend/services/pilot_flight_service.dart';

class AdminViewFlightLogScreen extends StatefulWidget {
  final CompanyFlightModel flight;

  const AdminViewFlightLogScreen({
    super.key,
    required this.flight,
  });

  @override
  State<AdminViewFlightLogScreen> createState() =>
      _AdminViewFlightLogScreenState();
}

class _AdminViewFlightLogScreenState extends State<AdminViewFlightLogScreen> {
  final PilotFlightService _service = PilotFlightService();
  late Future<FlightLogModel?> _logFuture;

  @override
  void initState() {
    super.initState();
    _logFuture = _service.getFlightLogByFlight(widget.flight.id);
  }

  /// Descargar PDF mediante url_launcher
  Future<void> _downloadPdf(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to open download link."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
          FutureBuilder<FlightLogModel?>(
            future: _logFuture,
            builder: (_, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: "Download PDF",
                icon: const Icon(Icons.download),
                onPressed: () => _downloadPdf(snapshot.data!.pdfUrl),
              );
            },
          ),
        ],
      ),

      // ========================= BODY ==========================
      body: FutureBuilder<FlightLogModel?>(
        future: _logFuture,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
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

          // WITHOUT LOG
          if (log == null) {
            return const Center(
              child: Text(
                'No flight log found for this flight.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // DISPLAY PDF
          return PDF().cachedFromUrl(
            log.pdfUrl,
            placeholder: (progress) => Center(
              child: Text('Loading PDF... $progress%'),
            ),
            errorWidget: (error) => Center(
              child: Text(
                'Error displaying PDF:\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}
