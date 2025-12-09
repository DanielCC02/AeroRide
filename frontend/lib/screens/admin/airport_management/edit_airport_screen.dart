import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/airport_model.dart';
import '../../../services/airport_service.dart';

/// Pantalla que permite al administrador editar los datos de un aeropuerto existente.
class EditAirportScreen extends StatefulWidget {
  final Airport airport;

  const EditAirportScreen({super.key, required this.airport});

  @override
  State<EditAirportScreen> createState() => _EditAirportScreenState();
}

class _EditAirportScreenState extends State<EditAirportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _airportService = AirportService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Controladores normales
  late TextEditingController _name;
  late TextEditingController _codeIATA;
  late TextEditingController _codeOACI;
  late TextEditingController _city;
  late TextEditingController _country;
  late TextEditingController _latitude;
  late TextEditingController _longitude;
  late TextEditingController _timeZone;
  late TextEditingController _openingTime;
  late TextEditingController _closingTime;
  late TextEditingController _maxAllowedWeight;
  late TextEditingController _departureMargin;
  late TextEditingController _arrivalMargin;

  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    final airport = widget.airport;

    _name = TextEditingController(text: airport.name);
    _codeIATA = TextEditingController(text: airport.codeIATA);
    _codeOACI = TextEditingController(text: airport.codeOACI);
    _city = TextEditingController(text: airport.city);
    _country = TextEditingController(text: airport.country);
    _latitude = TextEditingController(text: airport.latitude.toString());
    _longitude = TextEditingController(text: airport.longitude.toString());
    _timeZone = TextEditingController(text: airport.timeZone);
    _openingTime = TextEditingController(text: airport.openingTime ?? '');
    _closingTime = TextEditingController(text: airport.closingTime ?? '');
    _maxAllowedWeight =
        TextEditingController(text: airport.maxAllowedWeight?.toString() ?? '');
    _departureMargin = TextEditingController(
        text: airport.departureMarginMinutes.toString());
    _arrivalMargin =
        TextEditingController(text: airport.arrivalMarginMinutes.toString());

    _imageUrl = airport.image;
  }

  @override
  void dispose() {
    _name.dispose();
    _codeIATA.dispose();
    _codeOACI.dispose();
    _city.dispose();
    _country.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _timeZone.dispose();
    _openingTime.dispose();
    _closingTime.dispose();
    _maxAllowedWeight.dispose();
    _departureMargin.dispose();
    _arrivalMargin.dispose();
    super.dispose();
  }

  // ======================================================
  // Seleccionar y subir nueva imagen
  // ======================================================
  Future<void> _pickImage() async {
    final messenger = ScaffoldMessenger.of(context);

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      if (mounted) setState(() => _isLoading = true);

      final file = File(picked.path);
      final uploadedUrl = await _airportService.uploadAirportImage(file);

      if (mounted) setState(() => _imageUrl = uploadedUrl);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('⚠️ Error al subir imagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================================================
  // Guardar cambios
  // ======================================================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _airportService.updateAirport(
        id: widget.airport.id,
        name: _name.text.trim(),
        codeIATA: _codeIATA.text.trim(),
        codeOACI: _codeOACI.text.trim(),
        city: _city.text.trim(),
        country: _country.text.trim(),
        latitude: double.parse(_latitude.text.trim()),
        longitude: double.parse(_longitude.text.trim()),
        timeZone: _timeZone.text.trim(),
        openingTime: _openingTime.text.trim().isEmpty
            ? null
            : _openingTime.text.trim(),
        closingTime: _closingTime.text.trim().isEmpty
            ? null
            : _closingTime.text.trim(),
        maxAllowedWeight: int.tryParse(_maxAllowedWeight.text.trim()),
        imageUrl: _imageUrl,

        departureMarginMinutes: int.tryParse(_departureMargin.text.trim()),
        arrivalMarginMinutes: int.tryParse(_arrivalMargin.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Aeropuerto actualizado correctamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Airport')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen editable
                GestureDetector(
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
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.camera_alt, size: 50),
                              ),
                      ),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 32),
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Campos editables
                _buildField(_name, 'Name', 'Enter name'),
                _buildField(_codeIATA, 'Code IATA', 'Enter IATA code'),
                _buildField(_codeOACI, 'Code OACI', 'Enter OACI code'),
                _buildField(_city, 'City', 'Enter city'),
                _buildField(_country, 'Country', 'Enter country'),
                _buildField(_latitude, 'Latitude', 'Enter latitude',
                    isNumeric: true),
                _buildField(_longitude, 'Longitude', 'Enter longitude',
                    isNumeric: true),
                _buildField(_timeZone, 'Time Zone', 'Enter timezone'),
                _buildField(_openingTime, 'Opening Time (HH:mm:ss)', 'Optional'),
                _buildField(_closingTime, 'Closing Time (HH:mm:ss)', 'Optional'),
                _buildField(_maxAllowedWeight, 'Max Allowed Weight (kg)',
                    'Optional',
                    isNumeric: true),

                _buildField(_departureMargin, 'Departure Margin (minutes)',
                    'Enter minutes',
                    isNumeric: true),
                _buildField(_arrivalMargin, 'Arrival Margin (minutes)',
                    'Enter minutes',
                    isNumeric: true),

                const SizedBox(height: 24),

                // Botón Guardar
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
        ),
      ),
    );
  }

  // Campo reutilizable
  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Enter a valid $label' : null,
      ),
    );
  }
}
