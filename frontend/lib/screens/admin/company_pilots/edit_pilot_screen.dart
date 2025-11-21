import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/services/pilot_flight_service.dart';

/// Pantalla que permite editar la información de un piloto.
class EditPilotScreen extends StatefulWidget {
  final UserModel user;

  const EditPilotScreen({super.key, required this.user});

  @override
  State<EditPilotScreen> createState() => _EditPilotScreenState();
}

class _EditPilotScreenState extends State<EditPilotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final PilotFlightService _pilotFlightService = PilotFlightService();

  bool _isLoading = false;

  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _email;
  late TextEditingController _phone;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.user.name);
    _lastName = TextEditingController(text: widget.user.lastName);
    _email = TextEditingController(text: widget.user.email);
    _phone = TextEditingController(text: widget.user.phoneNumber);
    _isActive = widget.user.isActive;
  }

  /// Revisa si el piloto tiene vuelos FUTUROS asignados
  Future<bool> _pilotHasFutureFlights() async {
    try {
      final flights =
          await _pilotFlightService.getFlightsByPilot(widget.user.id);

      final now = DateTime.now();

      // Solo vuelos futuros
      final futureFlights =
          flights.where((f) => f.departureTime.isAfter(now)).toList();

      return futureFlights.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking pilot future flights: $e");
      return false; // No bloquear en caso de error inesperado
    }
  }

  /// Guarda cambios del formulario
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _userService.updatePilotByCompanyAdmin(
        id: widget.user.id,
        name: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        phoneNumber: _phone.text.trim(),
        isActive: _isActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilot updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error updating pilot: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating pilot: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pilot')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter first name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter last name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter phone number' : null,
              ),

              const SizedBox(height: 12),

              /// Switch de activación con bloqueo de pilotos con vuelos FUTUROS
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (newValue) async {
                  // Si el admin intenta DESACTIVAR el piloto
                  if (!newValue) {
                    final hasFutureFlights = await _pilotHasFutureFlights();

                    if (hasFutureFlights) {
                      if (!mounted) return;

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Action not allowed"),
                          content: const Text(
                            "The selected pilot has future assigned flights.\n\n"
                            "Please reassign those flights to another pilot before deactivating.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );

                      return; // No permitir desactivarlo
                    }
                  }

                  // Si llegó aquí → permitido cambiar
                  setState(() => _isActive = newValue);
                },
              ),

              const SizedBox(height: 24),

              // Botón para guardar cambios
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
    );
  }
}
