import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:frontend/providers/company_id_provider.dart';
import 'package:frontend/models/airport_model.dart';
import 'package:frontend/services/aircraft_service.dart';
import 'package:frontend/services/airport_service.dart';

class CreateAircraftScreen extends StatefulWidget {
  const CreateAircraftScreen({super.key});

  @override
  State<CreateAircraftScreen> createState() => _CreateAircraftScreenState();
}

class _CreateAircraftScreenState extends State<CreateAircraftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aircraftService = AircraftService();
  final _airportService = AirportService();
  final ImagePicker _picker = ImagePicker();

  // Controladores
  final _patent = TextEditingController();
  final _model = TextEditingController();
  final _minuteCost = TextEditingController();
  final _seats = TextEditingController();
  final _emptyWeight = TextEditingController();
  final _maxWeight = TextEditingController();
  final _cruisingSpeed = TextEditingController();

  bool _canFlyInternational = false;
  String _state = 'Disponible';

  Airport? _selectedBaseAirport;
  Airport? _selectedCurrentAirport;

  bool _isLoading = false;
  File? _selectedImage;

  late Future<List<Airport>> _airportsFuture;

  @override
  void initState() {
    super.initState();
    _airportsFuture = _airportService.getActiveAirports();
  }

  // ======================================================
  // Seleccionar imagen
  // ======================================================
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // ======================================================
  // Crear aeronave (subiendo la imagen ANTES)
  // ======================================================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBaseAirport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione el aeropuerto base')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una imagen')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final companyId =
          Provider.of<CompanyIdProvider>(context, listen: false).companyId;

      if (companyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el companyId')),
        );
        return;
      }

      // 1️⃣ SUBIR LA IMAGEN PRIMERO (igual que CreateAirportScreen)
      final imageUrl = await _aircraftService.uploadImageFile(_selectedImage!);

      // 2️⃣ CREAR LA AERONAVE (ya con imageUrl)
      await _aircraftService.createAircraft(
        companyId: companyId,
        baseAirportId: _selectedBaseAirport!.id,
        currentAirportId: _selectedCurrentAirport?.id,
        patent: _patent.text.trim(),
        model: _model.text.trim(),
        minuteCost: double.parse(_minuteCost.text.trim()),
        seats: int.parse(_seats.text.trim()),
        emptyWeight: int.parse(_emptyWeight.text.trim()),
        maxWeight: int.parse(_maxWeight.text.trim()),
        cruisingSpeed: double.parse(_cruisingSpeed.text.trim()),
        canFlyInternational: _canFlyInternational,
        state: _state,
        image: imageUrl, // ⭐ EXACTAMENTE IGUAL QUE CREATE AIRPORT SCREEN
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Aeronave creada correctamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ Error al crear aeronave: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _patent.dispose();
    _model.dispose();
    _minuteCost.dispose();
    _seats.dispose();
    _emptyWeight.dispose();
    _maxWeight.dispose();
    _cruisingSpeed.dispose();
    super.dispose();
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Aircraft')),
      body: FutureBuilder<List<Airport>>(
        future: _airportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('⚠️ Error: ${snapshot.error}'),
            );
          }

          final airports = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_patent, 'Patent', 'Enter patent'),
                  const SizedBox(height: 12),
                  _buildTextField(_model, 'Model', 'Enter model'),
                  const SizedBox(height: 12),
                  _buildNumberField(
                      _minuteCost, 'Minute Cost', 'Enter minute cost'),
                  const SizedBox(height: 12),
                  _buildNumberField(_seats, 'Seats', 'Enter seats'),
                  const SizedBox(height: 12),
                  _buildNumberField(
                      _emptyWeight, 'Empty Weight (kg)', 'Enter empty weight'),
                  const SizedBox(height: 12),
                  _buildNumberField(
                      _maxWeight, 'Max Weight (kg)', 'Enter max weight'),
                  const SizedBox(height: 12),
                  _buildNumberField(_cruisingSpeed, 'Cruise Speed (km/h)',
                      'Enter cruise speed'),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Can Fly International'),
                    value: _canFlyInternational,
                    onChanged: (v) => setState(() => _canFlyInternational = v),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<Airport>(
                    decoration: const InputDecoration(labelText: 'Base Airport'),
                    items: airports
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text('${a.name} (${a.codeIATA})'),
                          ),
                        )
                        .toList(),
                    validator: (v) =>
                        v == null ? 'Seleccione aeropuerto base' : null,
                    onChanged: (v) => setState(() => _selectedBaseAirport = v),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<Airport>(
                    decoration: const InputDecoration(
                      labelText: 'Current Airport (optional)',
                    ),
                    items: airports
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text('${a.name} (${a.codeIATA})'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCurrentAirport = v),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'State'),
                    value: _state,
                    items: const [
                      DropdownMenuItem(
                          value: 'Disponible', child: Text('Disponible')),
                      DropdownMenuItem(
                          value: 'EnMantenimiento',
                          child: Text('En mantenimiento')),
                      DropdownMenuItem(
                          value: 'FueraDeServicio',
                          child: Text('Fuera de servicio')),
                    ],
                    onChanged: (v) => setState(() => _state = v ?? 'Disponible'),
                  ),
                  const SizedBox(height: 16),

                  if (_selectedImage != null)
                    Column(
                      children: [
                        Image.file(_selectedImage!,
                            height: 150, fit: BoxFit.cover),
                        const SizedBox(height: 8),
                      ],
                    ),

                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label:
                          Text(_isLoading ? 'Saving...' : 'Create Aircraft'),
                      onPressed: _isLoading ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ======================================================
  // Reusable Widgets
  // ======================================================
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String validatorMsg,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (v) =>
          v == null || v.isEmpty ? validatorMsg : null,
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    String validatorMsg,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (v) =>
          v == null || double.tryParse(v) == null ? validatorMsg : null,
    );
  }
}

/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:frontend/providers/company_id_provider.dart';
import 'package:frontend/models/airport_model.dart';
import 'package:frontend/services/aircraft_service.dart';
import 'package:frontend/services/airport_service.dart';

class CreateAircraftScreen extends StatefulWidget {
  const CreateAircraftScreen({super.key});

  @override
  State<CreateAircraftScreen> createState() => _CreateAircraftScreenState();
}

class _CreateAircraftScreenState extends State<CreateAircraftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aircraftService = AircraftService();
  final _airportService = AirportService();

  // Controladores
  final _patent = TextEditingController();
  final _model = TextEditingController();
  final _minuteCost = TextEditingController();
  final _seats = TextEditingController();
  final _emptyWeight = TextEditingController();
  final _maxWeight = TextEditingController();
  final _cruisingSpeed = TextEditingController();

  bool _canFlyInternational = false;
  String _state = 'Disponible'; // Estado por defecto

  Airport? _selectedBaseAirport;
  Airport? _selectedCurrentAirport;

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  late Future<List<Airport>> _airportsFuture;

  @override
  void initState() {
    super.initState();
    _airportsFuture = _airportService.getActiveAirports();
  }

  // ======================================================
  // Seleccionar imagen
  // ======================================================
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // ======================================================
  // Crear aeronave (y luego subir imagen si hay)
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
      final companyId = Provider.of<CompanyIdProvider>(
        context,
        listen: false,
      ).companyId;

      if (companyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el companyId')),
        );
        return;
      }

      // 1) Crear aeronave SIN imagen (image: null)
      final created = await _aircraftService.createAircraft(
        patent: _patent.text.trim(),
        model: _model.text.trim(),
        minuteCost: double.parse(_minuteCost.text.trim()),
        seats: int.parse(_seats.text.trim()),
        emptyWeight: int.parse(_emptyWeight.text.trim()),
        maxWeight: int.parse(_maxWeight.text.trim()),
        cruisingSpeed: double.parse(_cruisingSpeed.text.trim()),
        canFlyInternational: _canFlyInternational,
        state: _state,
        image: null, // la subimos luego si hay
        baseAirportId: _selectedBaseAirport!.id,
        currentAirportId: _selectedCurrentAirport?.id,
        companyId: companyId,
      );

      // 2) Si seleccionaste imagen, subirla usando el id recién creado
      if (_selectedImage != null) {
        try {
          await _aircraftService.uploadAircraftImage(
            created.id, // <-- id del avión creado
            _selectedImage!.path, // <-- ruta del archivo
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '⚠️ Aeronave creada, pero falló la subida de imagen: $e',
                ),
              ),
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Aeronave creada correctamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error al crear aeronave: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================================================
  // Dispose controladores
  // ======================================================
  @override
  void dispose() {
    _patent.dispose();
    _model.dispose();
    _minuteCost.dispose();
    _seats.dispose();
    _emptyWeight.dispose();
    _maxWeight.dispose();
    _cruisingSpeed.dispose();
    super.dispose();
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Aircraft')),
      body: FutureBuilder<List<Airport>>(
        future: _airportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('⚠️ Error al cargar aeropuertos: ${snapshot.error}'),
            );
          }

          final airports = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_patent, 'Patent', 'Enter patent'),
                  const SizedBox(height: 12),
                  _buildTextField(_model, 'Model', 'Enter model'),
                  const SizedBox(height: 12),
                  _buildNumberField(
                    _minuteCost,
                    'Minute Cost',
                    'Enter minute cost',
                  ),
                  const SizedBox(height: 12),
                  _buildNumberField(_seats, 'Seats', 'Enter seats'),
                  const SizedBox(height: 12),
                  _buildNumberField(
                    _emptyWeight,
                    'Empty Weight (kg)',
                    'Enter empty weight',
                  ),
                  const SizedBox(height: 12),
                  _buildNumberField(
                    _maxWeight,
                    'Max Weight (kg)',
                    'Enter max weight',
                  ),
                  const SizedBox(height: 12),
                  _buildNumberField(
                    _cruisingSpeed,
                    'Cruising Speed (km/h)',
                    'Enter speed',
                  ),
                  const SizedBox(height: 16),

                  // Puede volar internacionalmente
                  SwitchListTile(
                    title: const Text('Can Fly International'),
                    value: _canFlyInternational,
                    onChanged: (v) => setState(() => _canFlyInternational = v),
                  ),
                  const SizedBox(height: 12),

                  // Aeropuerto Base
                  DropdownButtonFormField<Airport>(
                    decoration: const InputDecoration(
                      labelText: 'Base Airport',
                    ),
                    initialValue: _selectedBaseAirport,
                    items: airports
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text('${a.name} (${a.codeIATA})'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedBaseAirport = value);
                    },
                    validator: (v) =>
                        v == null ? 'Seleccione aeropuerto base' : null,
                  ),
                  const SizedBox(height: 12),

                  // Aeropuerto Actual (opcional)
                  DropdownButtonFormField<Airport>(
                    decoration: const InputDecoration(
                      labelText: 'Current Airport (optional)',
                    ),
                    initialValue: _selectedCurrentAirport,
                    items: airports
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text('${a.name} (${a.codeIATA})'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCurrentAirport = value);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Estado técnico
                  DropdownButtonFormField<String>(
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
                  const SizedBox(height: 16),

                  // Imagen
                  if (_selectedImage != null)
                    Column(
                      children: [
                        Image.file(
                          _selectedImage!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),

                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de guardar
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
                      label: Text(_isLoading ? 'Saving...' : 'Create Aircraft'),
                      onPressed: _isLoading ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ======================================================
  // Widgets reutilizables
  // ======================================================
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String validatorMsg,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (v) => v == null || v.isEmpty ? validatorMsg : null,
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    String validatorMsg,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (v) =>
          v == null || double.tryParse(v) == null ? validatorMsg : null,
    );
  }
}
*/