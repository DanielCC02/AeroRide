import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/models/flight_log_model.dart';
import 'package:frontend/services/pilot_flight_service.dart';

class AdminViewFlightLogScreen extends StatefulWidget {
  final CompanyFlightModel flight;

  const AdminViewFlightLogScreen({super.key, required this.flight});

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

  @override
  Widget build(BuildContext context) {
    final routeText =
        '${widget.flight.departureAirportName ?? ''} → ${widget.flight.arrivalAirportName ?? ''}';

    return Scaffold(
      appBar: AppBar(title: Text('Flight Log – $routeText'), centerTitle: true),
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
