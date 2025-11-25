import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:signature/signature.dart';

// NUEVOS
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/services/pilot_flight_service.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:image/image.dart' as img;

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

  // NEW: RUNWAYS
  final _departureRunway = TextEditingController();
  final _arrivalRunway = TextEditingController();

  final SignatureController _signatureController = SignatureController(
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
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_signatureController.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Please sign the flight log."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // ============== FIRMA: Convert PNG to JPEG (FIX) =================
    final pngBytes = await _signatureController.toPngBytes();

    img.Image? decodedImage = img.decodePng(pngBytes!);
    final jpgBytes = img.encodeJpg(decodedImage!, quality: 90);

    final signatureImage = pw.MemoryImage(jpgBytes);

    // 2) Generate PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER ------------------------------------------------------
              pw.Center(
                child: pw.Text(
                  "AeroCaribe Flight Log",
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),

              // BASIC INFO --------------------------------------------------
              pw.SizedBox(height: 12),
              pw.Text(
                "Flight Information",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text("Flight ID:"),
                      pw.Text(widget.flight.id.toString()),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text("Route:"),
                      pw.Text(
                        "${widget.flight.departureAirportName} to ${widget.flight.arrivalAirportName}",
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text("Aircraft:"),
                      pw.Text(widget.flight.aircraftModel ?? ''),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text("Runways:"),
                      pw.Text(
                        "DEP: ${_departureRunway.text}   ARR: ${_arrivalRunway.text}",
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // TIMES -------------------------------------------------------
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
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text("Hobbs Start"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(_hobbsStart.text),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text("Hobbs End"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(_hobbsEnd.text),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text("Block Off"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(_blockOff.text),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text("Block On"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(_blockOn.text),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text("Airborne Time"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(_airborneTime.text),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text("PIC Time"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(_picTime.text),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text("SIC Time"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(_sicTime.text),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // FUEL -------------------------------------------------------
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
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text("Fuel Start"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(_fuelStart.text),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text("Fuel End"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(_fuelEnd.text),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // WEATHER -------------------------------------------------------
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

              pw.SizedBox(height: 20),

              // REMARKS -------------------------------------------------------
              pw.Text(
                "Remarks",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(_remarks.text),

              pw.SizedBox(height: 20),

              // SIGNATURE -------------------------------------------------------
              pw.Text(
                "Signature",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                height: 120,
                width: 300,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Image(signatureImage),
              ),

              pw.Spacer(),

              // FOOTER -------------------------------------------------------
              pw.Center(
                child: pw.Text(
                  "Generated automatically by AeroRide – ${DateTime.now().toLocal()}",
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    // 3) Save PDF locally
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/flight_log_${widget.flight.id}.pdf");
    await file.writeAsBytes(await pdf.save());

    // 4) Upload
    final pilotId = await TokenStorage.getUserId();
    final service = PilotFlightService();

    try {
      await service.saveFlightLog(
        flightId: widget.flight.id,
        pilotUserId: pilotId!,
        pdfFile: file,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text("Flight log uploaded successfully")),
      );

      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text("Error uploading log: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

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
              _section("Signature"),

              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => _signatureController.clear(),
                child: const Text("Clear Signature"),
              ),

              const SizedBox(height: 20),
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
}
