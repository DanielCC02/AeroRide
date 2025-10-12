import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

/// Pantalla que permite al administrador editar los datos de un usuario existente.
class EditUserScreen extends StatefulWidget {
  final UserModel user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  bool _isLoading = false;

  late TextEditingController _fullName;
  late TextEditingController _email;
  late String _role;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.user.fullName);
    _email = TextEditingController(text: widget.user.email);
    _role = widget.user.role;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _userService.updateUserByAdmin(
        id: widget.user.id,
        fullName: _fullName.text.trim(),
        email: _email.text.trim(),
        role: _role,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Usuario actualizado correctamente')),
        );
        Navigator.pop(context, true); // 👈 devuelve “true” al cerrar
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
      appBar: AppBar(title: const Text('Edit User')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a valid name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 12),

              // 🔹 Dropdown para rol
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Pilot', child: Text('Pilot')),
                  DropdownMenuItem(value: 'User', child: Text('User')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'User'),
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
      ),
    );
  }
}
