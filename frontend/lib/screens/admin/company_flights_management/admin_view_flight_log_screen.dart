import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/models/flight_log_model.dart';
import 'package:frontend/services/pilot_flight_service.dart';
import 'package:frontend/services/api_config.dart';

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

  PdfController? _pdfController;

  @override
  void initState() {
    super.initState();
    _logFuture = _service.getFlightLogByFlight(widget.flight.id);
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<Uint8List> _loadPdfBytes(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception("Error loading PDF");
  }

  String _normalizeUrl(String rawUrl) {
    String url = rawUrl.trim();

    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      url = "${ApiConfig.baseUrl}$url";
      url = url
          .replaceAll("//", "/")
          .replaceFirst("http:/", "http://")
          .replaceFirst("https:/", "https://");
    }

    return url;
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
              final log = snapshot.data;
              if (log == null) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.download),
                tooltip: "Download PDF",
                onPressed: () async {
                  final normalized = _normalizeUrl(log.pdfUrl);
                  final uri = Uri.parse(normalized);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Unable to open download link:\n$normalized"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              );
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
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final log = snapshot.data;

          if (log == null) {
            return const Center(
              child: Text(
                'No flight log found for this flight.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final pdfUrl = _normalizeUrl(log.pdfUrl);

          return FutureBuilder<Uint8List>(
            future: _loadPdfBytes(pdfUrl),
            builder: (context, pdfSnapshot) {
              if (pdfSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (pdfSnapshot.hasError || pdfSnapshot.data == null) {
                return Center(
                  child: Text(
                    'Error loading PDF:\n${pdfSnapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final pdfData = pdfSnapshot.data!;
              _pdfController ??= PdfController(
                document: PdfDocument.openData(pdfData),
              );

              return PdfView(
                controller: _pdfController!,
                scrollDirection: Axis.vertical,
                pageSnapping: true,
              );
            },
          );
        },
      ),
    );
  }
}
