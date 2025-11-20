import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:frontend/models/company_flight_model.dart';

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
    if (!_formKey.currentState!.validate()) return;

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please sign the flight log."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Convert signature to PNG
    final signatureBytes = await _signatureController.toPngBytes();

    final jsonData = {
      "flightId": widget.flight.id,
      "hobbsStart": _hobbsStart.text,
      "hobbsEnd": _hobbsEnd.text,
      "blockOff": _blockOff.text,
      "blockOn": _blockOn.text,
      "fuelStart": _fuelStart.text,
      "fuelEnd": _fuelEnd.text,
      "metar": _metar.text,
      "taf": _taf.text,
      "remarks": _remarks.text,
      "signatureBase64": signatureBytes != null ? signatureBytes.toString() : '',
    };

    print("🔵 FLIGHT LOG JSON:");
    print(jsonData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Flight log saved (local mock).")),
    );

    Navigator.pop(context, true);
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

  Widget _input(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
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
      appBar: AppBar(
        title: const Text("Flight Log"),
        centerTitle: true,
      ),
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
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.flight.departureAirportName} → ${widget.flight.arrivalAirportName}",
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
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

              _input("Hobbs Start", _hobbsStart,
                  type: TextInputType.number),
              const SizedBox(height: 12),

              _input("Hobbs End", _hobbsEnd,
                  type: TextInputType.number),
              const SizedBox(height: 12),

              _input("Block Off (HH:MM)", _blockOff),
              const SizedBox(height: 12),

              _input("Block On (HH:MM)", _blockOn),

              const SizedBox(height: 20),

              // FUEL ----------------------------------------------------
              _buildSectionTitle("Fuel"),

              _input("Fuel Start (lbs/gal)", _fuelStart,
                  type: TextInputType.number),
              const SizedBox(height: 12),

              _input("Fuel End (lbs/gal)", _fuelEnd,
                  type: TextInputType.number),

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
