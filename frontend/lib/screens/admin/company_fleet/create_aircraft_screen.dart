import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; 
import 'package:frontend/providers/company_id_provider.dart';
import '../../../services/aircraft_service.dart';

class CreateAircraftScreen extends StatefulWidget {
  const CreateAircraftScreen({super.key});

  @override
  State<CreateAircraftScreen> createState() => _CreateAircraftScreenState();
}

class _CreateAircraftScreenState extends State<CreateAircraftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aircraftService = AircraftService();

  final _patent = TextEditingController();
  final _model = TextEditingController();
  final _price = TextEditingController();
  final _seats = TextEditingController();
  final _maxWeight = TextEditingController();
  String _state = 'Disponible'; // Estado por defecto

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // ======================================================
  // 🔹 Seleccionar imagen desde galería
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
  // 🔹 Crear aeronave (con subida de imagen y companyId)
  // ======================================================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Obtener el companyId desde el Provider
      final companyId = Provider.of<CompanyIdProvider>(context, listen: false).companyId;

      print('CreateAircraftScreen - companyId: $companyId');

      if (companyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el companyId')),
        );
        return;
      }

      String? imageUrl;

      // 🔹 Subir imagen si el usuario seleccionó una
      if (_selectedImage != null) {
        print('📤 Subiendo imagen de aeronave...');
        imageUrl = await _aircraftService.uploadAircraftImage(_selectedImage!);
        print('✅ Imagen subida con URL: $imageUrl');
      }

      // 🔹 Crear aeronave
      await _aircraftService.createAircraft(
        patent: _patent.text.trim(),
        model: _model.text.trim(),
        price: double.parse(_price.text.trim()),
        seats: int.parse(_seats.text.trim()),
        maxWeight: int.parse(_maxWeight.text.trim()),
        state: _state,
        image: imageUrl,
        companyId: companyId, // 👈 Se pasa automáticamente desde el Provider
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Aeronave creada correctamente')),
        );
        Navigator.pop(context, true); // 🔁 Devuelve "true" para refrescar la lista
      }
    } catch (e) {
      print('❌ Error al crear aeronave: $e');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Aircraft')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _patent,
                decoration: const InputDecoration(labelText: 'Patent'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter patent' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _model,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter model' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Enter price'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _seats,
                decoration: const InputDecoration(labelText: 'Seats'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || int.tryParse(v) == null ? 'Enter seats' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _maxWeight,
                decoration: const InputDecoration(labelText: 'Max Weight'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Enter max weight'
                    : null,
              ),
              const SizedBox(height: 12),

              // 🔹 Dropdown de estado
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'State'),
                value: _state,
                items: const [
                  DropdownMenuItem(
                    value: 'Disponible',
                    child: Text('Disponible'),
                  ),
                  DropdownMenuItem(value: 'EnVuelo', child: Text('En vuelo')),
                  DropdownMenuItem(
                    value: 'EnMantenimiento',
                    child: Text('En mantenimiento'),
                  ),
                  DropdownMenuItem(
                    value: 'FueraDeServicio',
                    child: Text('Fuera de servicio'),
                  ),
                ],
                onChanged: (v) => setState(() => _state = v ?? 'Disponible'),
              ),
              const SizedBox(height: 16),

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

              // 🔹 Botón para crear aeronave
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
      ),
    );
  }
}
