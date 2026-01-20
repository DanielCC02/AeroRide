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

  // ==============================
  // FETCH PDF BYTES
  // ==============================
  Future<Uint8List> _loadPdfBytes(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception("Error loading PDF");
  }

  // ==============================
  // NORMALIZE URL
  // ==============================
  String _normalizeUrl(String rawUrl) {
    final url = rawUrl.trim();

    if (url.startsWith("http://") || url.startsWith("https://")) {
      return url;
    }

    return "${ApiConfig.baseUrl}$url"
        .replaceAll("//", "/")
        .replaceFirst("http:/", "http://")
        .replaceFirst("https:/", "https://");
  }

  // ==============================
  // DOWNLOAD HANDLER (with Fallback)
  // ==============================
  Future<void> _handleDownload(String rawUrl) async {
    final url = _normalizeUrl(rawUrl);
    final uri = Uri.parse(url);

    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // =============================================
    // iOS → ABRIR EN SAFARI (platformDefault)
    // =============================================
    if (isIOS) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (launched) return;
      } catch (_) {}
    } else {
      // =============================================
      // Android → navegador externo
      // =============================================
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      } catch (_) {}
    }

    // =============================================
    // Google Docs Viewer fallback universal
    // =============================================
    final viewerUrl =
        "https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true";

    final viewerUri = Uri.parse(viewerUrl);

    try {
      final launched = await launchUrl(
        viewerUri,
        mode: LaunchMode.inAppWebView,
      );
      if (launched) return;
    } catch (_) {}

    // =============================================
    // iOS fallback final → Safari sí o sí
    // =============================================
    if (isIOS) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        return;
      } catch (_) {}
    }

    // =============================================
    // FALLO FINAL
    // =============================================
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unable to open PDF:\n$url")),
    );
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
                tooltip: "Download PDF",
                icon: const Icon(Icons.download),
                onPressed: () => _handleDownload(log.pdfUrl),
              );
            },
          ),
        ],
      ),

      // ========================= BODY ============================
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
