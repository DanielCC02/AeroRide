import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/aircraft_model.dart';
import '../../services/aircraft_service.dart';

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
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  late TextEditingController _patent;
  late TextEditingController _model;
  late TextEditingController _price;
  late TextEditingController _seats;
  late TextEditingController _maxWeight;
  late String _state;

  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _patent = TextEditingController(text: widget.aircraft.patent);
    _model = TextEditingController(text: widget.aircraft.model);
    _price = TextEditingController(text: widget.aircraft.price.toString());
    _seats = TextEditingController(text: widget.aircraft.seats.toString());
    _maxWeight = TextEditingController(
      text: widget.aircraft.maxWeight.toString(),
    );
    _state = widget.aircraft.state;
    _imageUrl = widget.aircraft.image;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      try {
        setState(() => _isLoading = true);

        // ✅ Convertir XFile → File
        final file = File(picked.path);

        // ✅ Subir imagen al backend (Azure)
        final uploadedUrl = await _aircraftService.uploadAircraftImage(file);

        setState(() => _imageUrl = uploadedUrl);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('⚠️ Error al subir imagen: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _aircraftService.updateAircraft(
        id: widget.aircraft.id,
        patent: _patent.text.trim(),
        model: _model.text.trim(),
        price: double.parse(_price.text.trim()),
        seats: int.parse(_seats.text.trim()),
        maxWeight: int.parse(_maxWeight.text.trim()),
        state: _state,
        imageUrl: _imageUrl,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Aircraft')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen (clickeable para cambiar)
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

                        // 🔹 Overlay visual para indicar acción
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
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

                        // 🔹 Indicador de carga
                        if (_isLoading)
                          Container(
                            height: 200,
                            width: double.infinity,
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
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _patent,
                  decoration: const InputDecoration(labelText: 'Patent'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter the patent' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _model,
                  decoration: const InputDecoration(labelText: 'Model'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter the model' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _seats,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Seats'),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _maxWeight,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max Weight'),
                ),
                const SizedBox(height: 12),

                // 🔹 Dropdown para estado operativo (enum)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'State'),
                  initialValue: _state,
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

                const SizedBox(height: 32),

                // 🔹 Botón Guardar
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
}
