import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/airport_service.dart';

class CreateAirportScreen extends StatefulWidget {
  const CreateAirportScreen({super.key});

  @override
  State<CreateAirportScreen> createState() => _CreateAirportScreenState();
}

class _CreateAirportScreenState extends State<CreateAirportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _airportService = AirportService();

  // 🧱 Controladores
  final _name = TextEditingController();
  final _codeIATA = TextEditingController();
  final _codeOACI = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  final _timeZone = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _maxWeight = TextEditingController();
  final _openingTime = TextEditingController();
  final _closingTime = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // ======================================================
  // 📸 Seleccionar imagen desde galería
  // ======================================================
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      print('📸 Imagen seleccionada: ${pickedFile.path}');
    }
  }

  // ======================================================
  // ✈️ Crear aeropuerto (con subida de imagen)
  // ======================================================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una imagen')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔹 Subir imagen primero
      print('📤 Subiendo imagen de aeropuerto...');
      final imageUrl = await _airportService.uploadAirportImage(_selectedImage!);
      print('✅ Imagen subida con URL: $imageUrl');

      // 🔹 Crear aeropuerto
      await _airportService.createAirport(
        name: _name.text.trim(),
        codeIATA: _codeIATA.text.trim().toUpperCase(),
        codeOACI: _codeOACI.text.trim().toUpperCase(),
        city: _city.text.trim(),
        country: _country.text.trim(),
        timeZone: _timeZone.text.trim(),
        latitude: double.parse(_latitude.text.trim()),
        longitude: double.parse(_longitude.text.trim()),
        imageUrl: imageUrl,
        maxAllowedWeight: _maxWeight.text.isNotEmpty
            ? int.parse(_maxWeight.text.trim())
            : null,
        openingTime: _openingTime.text.isNotEmpty
            ? _openingTime.text.trim()
            : null,
        closingTime: _closingTime.text.isNotEmpty
            ? _closingTime.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Aeropuerto creado correctamente')),
        );
        Navigator.pop(context, true); // 🔁 Regresa y refresca la lista
      }
    } catch (e) {
      print('❌ Error al crear aeropuerto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================================================
  // 🧹 Dispose controladores
  // ======================================================
  @override
  void dispose() {
    _name.dispose();
    _codeIATA.dispose();
    _codeOACI.dispose();
    _city.dispose();
    _country.dispose();
    _timeZone.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _maxWeight.dispose();
    _openingTime.dispose();
    _closingTime.dispose();
    super.dispose();
  }

  // ======================================================
  // 🧩 UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Airport')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_name, 'Airport Name', 'Enter airport name'),
              const SizedBox(height: 12),
              _buildTextField(_codeIATA, 'Code IATA (3 letters)', 'Enter IATA code',
                  textCapitalization: TextCapitalization.characters),
              const SizedBox(height: 12),
              _buildTextField(_codeOACI, 'Code OACI (4 letters)', 'Enter OACI code',
                  textCapitalization: TextCapitalization.characters),
              const SizedBox(height: 12),
              _buildTextField(_city, 'City', 'Enter city'),
              const SizedBox(height: 12),
              _buildTextField(_country, 'Country', 'Enter country'),
              const SizedBox(height: 12),
              _buildTextField(_timeZone, 'Time Zone (e.g., America/Costa_Rica)', 'Enter time zone'),
              const SizedBox(height: 12),
              _buildNumberField(_latitude, 'Latitude', 'Enter latitude (-90 to 90)'),
              const SizedBox(height: 12),
              _buildNumberField(_longitude, 'Longitude', 'Enter longitude (-180 to 180)'),
              const SizedBox(height: 12),
              _buildOptionalNumberField(_maxWeight, 'Max Allowed Weight (kg)'),
              const SizedBox(height: 12),
              _buildOptionalTextField(_openingTime, 'Opening Time (HH:mm:ss)'),
              const SizedBox(height: 12),
              _buildOptionalTextField(_closingTime, 'Closing Time (HH:mm:ss)'),
              const SizedBox(height: 20),

              // 🔹 Imagen seleccionada (preview)
              if (_selectedImage != null)
                Column(
                  children: [
                    Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                  ],
                ),

              // 🔹 Botón para seleccionar imagen
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

              // 🔹 Botón para crear aeropuerto
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
                  label: Text(_isLoading ? 'Saving...' : 'Create Airport'),
                  onPressed: _isLoading ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // 🔹 Campos reutilizables
  // ======================================================
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String validatorMsg, {
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(labelText: label),
      validator: (v) => v == null || v.isEmpty ? validatorMsg : null,
    );
  }

  Widget _buildNumberField(
      TextEditingController controller, String label, String validatorMsg) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (v) => v == null || double.tryParse(v) == null
          ? validatorMsg
          : null,
    );
  }

  Widget _buildOptionalNumberField(
      TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: '$label (optional)'),
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v != null && v.isNotEmpty && int.tryParse(v) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildOptionalTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: '$label (optional)'),
    );
  }
}
