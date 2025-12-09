import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:signature/signature.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/services/pilot_flight_service.dart';
import 'package:frontend/services/token_storage.dart';

class FlightLogFormScreen extends StatefulWidget {
  final CompanyFlightModel flight;

  const FlightLogFormScreen({super.key, required this.flight});

  @override
  State<FlightLogFormScreen> createState() => _FlightLogFormScreenState();
}

class _FlightLogFormScreenState extends State<FlightLogFormScreen> {
  // TIMES
  final _hobbsStart = TextEditingController();
  final _hobbsEnd = TextEditingController();
  final _blockOff = TextEditingController();
  final _blockOn = TextEditingController();

  // NEW: AIRBORNE + PIC + SIC
  final _airborneTime = TextEditingController();
  final _picTime = TextEditingController();
  final _sicTime = TextEditingController();

  // FUEL
  final _fuelStart = TextEditingController();
  final _fuelEnd = TextEditingController();

  // WEATHER
  final _metar = TextEditingController();
  final _taf = TextEditingController();
  final _remarks = TextEditingController();

  // RUNWAYS
  final _departureRunway = TextEditingController();
  final _arrivalRunway = TextEditingController();

  // SIGNATURES
  final SignatureController _pilotSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  final SignatureController _copilotSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _hobbsStart.dispose();
    _hobbsEnd.dispose();
    _blockOff.dispose();
    _blockOn.dispose();
    _airborneTime.dispose();
    _picTime.dispose();
    _sicTime.dispose();
    _fuelStart.dispose();
    _fuelEnd.dispose();
    _metar.dispose();
    _taf.dispose();
    _remarks.dispose();
    _departureRunway.dispose();
    _arrivalRunway.dispose();

    _pilotSignatureController.dispose();
    _copilotSignatureController.dispose();

    super.dispose();
  }

  // EXPORT SIGNATURE WITH WHITE BACKGROUND
  Future<Uint8List> _exportSignature(SignatureController controller) async {
    final exportController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    exportController.points = List.from(controller.points);

    final png = await exportController.toPngBytes();

    if (png == null || png.isEmpty) {
      throw Exception("Signature export failed");
    }

    return png;
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d, yyyy – hh:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text("Flight Log"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section("Flight Information"),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.flight.departureAirportName} → ${widget.flight.arrivalAirportName}",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(df.format(widget.flight.departureLocal)),
                      Text(df.format(widget.flight.arrivalLocal)),
                      const SizedBox(height: 10),
                      Text("Aircraft: ${widget.flight.aircraftModel}"),
                      Text("Duration: ${widget.flight.duration.inMinutes} min"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _section("Runways"),

              _input("Departure Runway", _departureRunway),
              const SizedBox(height: 12),
              _input("Arrival Runway", _arrivalRunway),

              const SizedBox(height: 20),
              _section("Times"),

              _input("Hobbs Start", _hobbsStart, type: TextInputType.number),
              const SizedBox(height: 12),
              _input("Hobbs End", _hobbsEnd, type: TextInputType.number),
              const SizedBox(height: 12),
              _input("Block Off (HH:MM)", _blockOff),
              const SizedBox(height: 12),
              _input("Block On (HH:MM)", _blockOn),
              const SizedBox(height: 12),
              _input("Airborne Time (HH:MM)", _airborneTime),

              const SizedBox(height: 20),
              _section("Crew Times"),

              _input("PIC Time (HH:MM)", _picTime),
              const SizedBox(height: 12),
              _input("SIC Time (HH:MM)", _sicTime),

              const SizedBox(height: 20),
              _section("Fuel"),

              _input("Fuel Start", _fuelStart, type: TextInputType.number),
              const SizedBox(height: 12),
              _input("Fuel End", _fuelEnd, type: TextInputType.number),

              const SizedBox(height: 20),
              _section("Weather"),

              _input("METAR", _metar),
              const SizedBox(height: 12),
              _input("TAF", _taf),

              const SizedBox(height: 20),
              _section("Remarks"),

              _input("Remarks / Notes", _remarks),

              const SizedBox(height: 20),
              _section("Pilot Signature (Required)"),

              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Signature(
                  controller: _pilotSignatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => _pilotSignatureController.clear(),
                child: const Text("Clear Pilot Signature"),
              ),

              const SizedBox(height: 20),
              _section("Copilot Signature (Optional)"),

              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Signature(
                  controller: _copilotSignatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => _copilotSignatureController.clear(),
                child: const Text("Clear Copilot Signature"),
              ),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Save Flight Log"),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================================
  // PDF GENERATION + UPLOAD
  // ==================================================================

  Future<void> _submitForm() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!_formKey.currentState!.validate()) return;

    // Pilot signature required
    if (_pilotSignatureController.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Pilot signature is required."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Export signatures
    final pilotSignatureBytes = await _exportSignature(
      _pilotSignatureController,
    );

    Uint8List? copilotSignatureBytes;
    if (_copilotSignatureController.isNotEmpty) {
      copilotSignatureBytes = await _exportSignature(
        _copilotSignatureController,
      );
    }

    final pilotSignature = pw.MemoryImage(pilotSignatureBytes);
    final copilotSignature = copilotSignatureBytes != null
        ? pw.MemoryImage(copilotSignatureBytes)
        : null;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),

        // FOOTER AUTOMÁTICO EN TODAS LAS PÁGINAS
        footer: (context) => pw.Center(
          child: pw.Text(
            "Generated automatically by AeroCaribe ${DateTime.now().toLocal()}",
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),

        build: (pw.Context context) => [
          // TITLE
          pw.Center(
            child: pw.Text(
              "AeroCaribe Flight Log",
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(),

          // FLIGHT INFORMATION
          pw.SizedBox(height: 12),
          pw.Text(
            "Flight Information",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),

          pw.Table(
            columnWidths: {0: pw.FlexColumnWidth(2), 1: pw.FlexColumnWidth(3)},
            children: [
              _infoRow("Company", widget.flight.companyName ?? ""),
              _infoRow(
                "Route",
                "${widget.flight.departureAirportName} to ${widget.flight.arrivalAirportName}",
              ),
              _infoRow("Aircraft", widget.flight.aircraftModel ?? ""),
              _infoRow(
                "Runways",
                "DEP: ${_departureRunway.text}  ARR: ${_arrivalRunway.text}",
              ),
            ],
          ),

          pw.SizedBox(height: 25),

          // TIMES + FUEL + WEATHER
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN — TIMES
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Times",
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),

                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        _infoRow("Hobbs Start", _hobbsStart.text),
                        _infoRow("Hobbs End", _hobbsEnd.text),
                        _infoRow("Block Off", _blockOff.text),
                        _infoRow("Block On", _blockOn.text),
                        _infoRow("Airborne Time", _airborneTime.text),
                        _infoRow("PIC Time", _picTime.text),
                        _infoRow("SIC Time", _sicTime.text),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(width: 20),

              // RIGHT COLUMN — FUEL + WEATHER
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Fuel",
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),

                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        _infoRow("Fuel Start", _fuelStart.text),
                        _infoRow("Fuel End", _fuelEnd.text),
                      ],
                    ),

                    pw.SizedBox(height: 25),

                    pw.Text(
                      "Weather",
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),

                    pw.Text("METAR: ${_metar.text}"),
                    pw.Text("TAF: ${_taf.text}"),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          // REMARKS
          pw.Text(
            "Remarks",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(_remarks.text),
          pw.SizedBox(height: 30),

          // SIGNATURES
          pw.Text(
            "Signatures",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Pilot:"),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    height: 120,
                    width: 250,
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                    child: pw.Image(pilotSignature),
                  ),
                ],
              ),
              pw.SizedBox(width: 24),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Copilot:"),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    height: 120,
                    width: 250,
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                    child: copilotSignature != null
                        ? pw.Image(copilotSignature)
                        : pw.Center(
                            child: pw.Text(
                              "N/A",
                              style: pw.TextStyle(
                                color: PdfColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // SAVE AND UPLOAD
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/flight_log_${widget.flight.id}.pdf");
    await file.writeAsBytes(await pdf.save());

    final service = PilotFlightService();
    final pilotId = await TokenStorage.getUserId();

    try {
      await service.saveFlightLog(
        flightId: widget.flight.id,
        pilotUserId: pilotId!,
        pdfFile: file,
      );

      messenger.showSnackBar(
        const SnackBar(content: Text("Flight log uploaded successfully")),
      );

      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Error uploading log: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Helpers

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController c, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v == null || v.isEmpty ? "Required field" : null,
    );
  }

  pw.TableRow _infoRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(label)),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(value)),
      ],
    );
  }
}
