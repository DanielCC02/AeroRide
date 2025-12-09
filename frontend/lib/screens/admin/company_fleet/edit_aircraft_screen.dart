import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/aircraft_model.dart';
import '../../../models/airport_model.dart';
import '../../../services/aircraft_service.dart';
import '../../../services/airport_service.dart';

/// Pantalla que permite al administrador editar los datos de una aeronave existente.
class EditAircraftScreen extends StatefulWidget {
  final AircraftModel aircraft;

  const EditAircraftScreen({super.key, required this.aircraft});

  @override
  State<EditAircraftScreen> createState() => _EditAircraftScreenState();
}

class _EditAircraftScreenState extends State<EditAircraftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aircraftService = AircraftService();
  final _airportService = AirportService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Controladores
  late TextEditingController _patent;
  late TextEditingController _model;
  late TextEditingController _minuteCost;
  late TextEditingController _seats;
  late TextEditingController _emptyWeight;
  late TextEditingController _maxWeight;
  late TextEditingController _cruisingSpeed;
  bool _canFlyInternational = false;
  late String _state;
  String? _imageUrl;

  // Aeropuertos
  Airport? _selectedBaseAirport;
  Airport? _selectedCurrentAirport;
  late Future<List<Airport>> _airportsFuture;

  @override
  void initState() {
    super.initState();

    final a = widget.aircraft;

    _patent = TextEditingController(text: a.patent);
    _model = TextEditingController(text: a.model);
    _minuteCost = TextEditingController(text: a.minuteCost.toString());
    _seats = TextEditingController(text: a.seats.toString());
    _emptyWeight = TextEditingController(text: a.emptyWeight.toString());
    _maxWeight = TextEditingController(text: a.maxWeight.toString());
    _cruisingSpeed = TextEditingController(text: a.cruisingSpeed.toString());
    _canFlyInternational = a.canFlyInternational;
    _state = a.state;
    _imageUrl = a.image;

    _airportsFuture = _airportService.getActiveAirports();
  }

  // ======================================================
  // Seleccionar nueva imagen
  // ======================================================
  Future<void> _pickImage() async {
    // Usar context ANTES de cualquier await
    final messenger = ScaffoldMessenger.of(context);

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      final file = File(picked.path);
      final uploadedUrl = await _aircraftService.uploadAircraftImage(
        widget.aircraft.id, // ⬅️ id primero
        file.path, // ⬅️ path del archivo
      );

      if (mounted) {
        setState(() => _imageUrl = uploadedUrl);
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('⚠️ Error al subir imagen: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ======================================================
  // Guardar cambios
  // ======================================================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBaseAirport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione el aeropuerto base')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _aircraftService.updateAircraft(
        widget.aircraft.id, // ⬅️ id posicional obligatorio
        patent: _patent.text.trim(),
        model: _model.text.trim(),
        minuteCost: double.parse(_minuteCost.text.trim()),
        seats: int.parse(_seats.text.trim()),
        emptyWeight: int.parse(_emptyWeight.text.trim()),
        maxWeight: int.parse(_maxWeight.text.trim()),
        cruisingSpeed: double.parse(_cruisingSpeed.text.trim()),
        canFlyInternational: _canFlyInternational,
        state: _state,
        baseAirportId:
            _selectedBaseAirport?.id ?? widget.aircraft.baseAirportId,
        currentAirportId: _selectedCurrentAirport?.id,
        image: _imageUrl, // ⬅️ se llama `image`
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Aeronave actualizada correctamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('⚠️ Error al actualizar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================================================
  // Interfaz de usuario
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Aircraft')),
      body: SafeArea(
        child: FutureBuilder<List<Airport>>(
          future: _airportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  '⚠️ Error al cargar aeropuertos: ${snapshot.error}',
                ),
              );
            }

            final airports = snapshot.data ?? [];

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Imagen
                    Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _pickImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _imageUrl != null && _imageUrl!.isNotEmpty
                                  ? Image.network(
                                      _imageUrl!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Change Image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isLoading)
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(_patent, 'Patent', 'Enter the patent'),
                    _buildTextField(_model, 'Model', 'Enter the model'),
                    _buildNumberField(
                      _minuteCost,
                      'Minute Cost',
                      'Enter minute cost',
                    ),
                    _buildNumberField(_seats, 'Seats', 'Enter seats'),
                    _buildNumberField(
                      _emptyWeight,
                      'Empty Weight (kg)',
                      'Enter empty weight',
                    ),
                    _buildNumberField(
                      _maxWeight,
                      'Max Weight (kg)',
                      'Enter max weight',
                    ),
                    _buildNumberField(
                      _cruisingSpeed,
                      'Cruising Speed (km/h)',
                      'Enter speed',
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Can Fly International'),
                      value: _canFlyInternational,
                      onChanged: (v) =>
                          setState(() => _canFlyInternational = v),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<Airport>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Base Airport',
                      ),
                      initialValue: airports.firstWhere(
                        (a) => a.name == widget.aircraft.baseAirportName,
                        orElse: () => airports.first,
                      ),
                      items: airports
                          .map(
                            (a) => DropdownMenuItem(
                              value: a,
                              child: Text(
                                '${a.name} (${a.codeIATA})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedBaseAirport = v),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<Airport>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Airport (optional)',
                      ),
                      initialValue: airports.firstWhere(
                        (a) =>
                            a.name == widget.aircraft.currentAirportName &&
                            widget.aircraft.currentAirportName != null,
                        orElse: () => airports.first,
                      ),
                      items: airports
                          .map(
                            (a) => DropdownMenuItem(
                              value: a,
                              child: Text(
                                '${a.name} (${a.codeIATA})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCurrentAirport = v),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'State'),
                      initialValue: _state,
                      items: const [
                        DropdownMenuItem(
                          value: 'Disponible',
                          child: Text('Disponible'),
                        ),
                        DropdownMenuItem(
                          value: 'EnMantenimiento',
                          child: Text('En mantenimiento'),
                        ),
                        DropdownMenuItem(
                          value: 'FueraDeServicio',
                          child: Text('Fuera de servicio'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _state = v ?? 'Disponible'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                        onPressed: _isLoading ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ======================================================
  // Widgets auxiliares
  // ======================================================
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String validatorMsg,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null || v.isEmpty ? validatorMsg : null,
      ),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    String validatorMsg,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        validator: (v) =>
            v == null || double.tryParse(v) == null ? validatorMsg : null,
      ),
    );
  }
}
