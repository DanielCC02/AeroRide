import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

// NUEVOS
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
  // Controllers -----------------------------
  final _hobbsStart = TextEditingController();
  final _hobbsEnd = TextEditingController();
  final _blockOff = TextEditingController();
  final _blockOn = TextEditingController();
  final _fuelStart = TextEditingController();
  final _fuelEnd = TextEditingController();
  final _metar = TextEditingController();
  final _taf = TextEditingController();
  final _remarks = TextEditingController();

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  final _formKey = GlobalKey<FormState>();

  // ------------------------------------------

  @override
  void dispose() {
    _hobbsStart.dispose();
    _hobbsEnd.dispose();
    _blockOff.dispose();
    _blockOn.dispose();
    _fuelStart.dispose();
    _fuelEnd.dispose();
    _metar.dispose();
    _taf.dispose();
    _remarks.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 👇 Cacheamos helpers basados en context ANTES de cualquier await
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

    // ============== 1) Convert signature to bytes ==============
    final signatureBytes = await _signatureController.toPngBytes();

    // ============== 2) Generate PDF ============================
    final pdf = pw.Document();

    final signatureImage = signatureBytes != null
        ? pw.MemoryImage(signatureBytes)
        : null;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Flight Log", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text("Flight ID: ${widget.flight.id}"),
            pw.Text(
              "Route: ${widget.flight.departureAirportName} → ${widget.flight.arrivalAirportName}",
            ),
            pw.Text("Aircraft: ${widget.flight.aircraftModel}"),
            pw.SizedBox(height: 10),
            pw.Text("Hobbs Start: ${_hobbsStart.text}"),
            pw.Text("Hobbs End: ${_hobbsEnd.text}"),
            pw.Text("Block Off: ${_blockOff.text}"),
            pw.Text("Block On: ${_blockOn.text}"),
            pw.SizedBox(height: 10),
            pw.Text("Fuel Start: ${_fuelStart.text}"),
            pw.Text("Fuel End: ${_fuelEnd.text}"),
            pw.SizedBox(height: 10),
            pw.Text("METAR: ${_metar.text}"),
            pw.Text("TAF: ${_taf.text}"),
            pw.Text("Remarks: ${_remarks.text}"),
            pw.SizedBox(height: 20),
            pw.Text("Signature:"),
            if (signatureImage != null) pw.Image(signatureImage, width: 200),
          ],
        ),
      ),
    );

    // ============== 3) Save PDF in temp folder =================
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/flight_log_${widget.flight.id}.pdf");
    await file.writeAsBytes(await pdf.save());

    // ============== 4) Upload to backend ========================
    final pilotId = await TokenStorage.getUserId();
    final service = PilotFlightService();

    try {
      await service.saveFlightLog(
        flightId: widget.flight.id,
        pilotUserId: pilotId!, // mismo comportamiento que antes
        pdfFile: file,
      );

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(content: Text("Flight log uploaded successfully")),
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text("Error uploading log: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
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
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
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
              // FLIGHT HEADER -----------------------------------
              _buildSectionTitle("Flight Information"),

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

              // HOBBS & BLOCK TIME ------------------------------
              _buildSectionTitle("Times"),

              _input("Hobbs Start", _hobbsStart, type: TextInputType.number),
              const SizedBox(height: 12),

              _input("Hobbs End", _hobbsEnd, type: TextInputType.number),
              const SizedBox(height: 12),

              _input("Block Off (HH:MM)", _blockOff),
              const SizedBox(height: 12),

              _input("Block On (HH:MM)", _blockOn),

              const SizedBox(height: 20),

              // FUEL ----------------------------------------------------
              _buildSectionTitle("Fuel"),

              _input(
                "Fuel Start (lbs/gal)",
                _fuelStart,
                type: TextInputType.number,
              ),
              const SizedBox(height: 12),

              _input(
                "Fuel End (lbs/gal)",
                _fuelEnd,
                type: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // WEATHER ------------------------------------------------
              _buildSectionTitle("Weather"),

              _input("METAR", _metar),
              const SizedBox(height: 12),

              _input("TAF", _taf),
              const SizedBox(height: 12),

              _input("Remarks / Notes", _remarks),

              const SizedBox(height: 20),

              // SIGNATURE -------------------------------------------
              _buildSectionTitle("Signature"),

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

              // SAVE BUTTON --------------------------------------
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
