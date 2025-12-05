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

  /// DESCARGA EL PDF COMO BYTES (para el visor PdfX)
  Future<Uint8List> _loadPdfBytes(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception("Error loading PDF bytes");
  }

  /// NORMALIZA LA URL — evita romper las URLs de Azure Blob Storage
  String _normalizeUrl(String rawUrl) {
    final url = rawUrl.trim();

    // ⚠️ Si es absoluta (como Azure Blob Storage), NO tocarla
    if (url.startsWith("http://") || url.startsWith("https://")) {
      return url;
    }

    // ⚠️ Solo normalizar si es relativa
    return "${ApiConfig.baseUrl}$url"
        .replaceAll("//", "/")
        .replaceFirst("http:/", "http://")
        .replaceFirst("https:/", "https://");
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

              // =============================================
              // 1️⃣ Intentar abrir con un navegador externo
              // =============================================
              try {
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );

                if (launched) return; // Success!
              } catch (_) {
                // Ignorar, pasamos al fallback
              }

              // =============================================
              // 2️⃣ FALLBACK: Abrir en Google Docs Viewer
              // =============================================
              final viewerUrl =
                  "https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true";

              final viewerUri = Uri.parse(viewerUrl);

              try {
                final launched = await launchUrl(
                  viewerUri,
                  mode: LaunchMode.inAppWebView,
                );

                if (launched) return; // Success!
              } catch (_) {
                // ignorar y continuar al fallback final
              }

              // =============================================
              // 3️⃣ Si todo falla → mostrar error
              // =============================================
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Unable to open PDF:\n$url")),
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
