import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/models/flight_log_model.dart';
import 'package:frontend/services/api_config.dart';
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
    throw Exception("Error loading PDF bytes");
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
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final log = await _logFuture;

              if (log == null) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No log available to download")),
                );
                return;
              }

              final url = _normalizeUrl(log.pdfUrl);
              final uri = Uri.parse(url);

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Unable to open download link:\n$url")),
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

          final String pdfUrl = _normalizeUrl(log.pdfUrl);

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
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
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
