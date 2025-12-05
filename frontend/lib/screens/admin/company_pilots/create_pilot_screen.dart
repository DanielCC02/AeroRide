import 'package:flutter/material.dart';
import 'package:frontend/providers/company_id_provider.dart';
import 'package:frontend/services/user_service.dart';
import 'package:provider/provider.dart'; // Importar el provider

class CreatePilotScreen extends StatefulWidget {
  const CreatePilotScreen({super.key});

  @override
  State<CreatePilotScreen> createState() => _CreatePilotScreenState();
}

class _CreatePilotScreenState extends State<CreatePilotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final UserService _userService = UserService();

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Acceder al companyId desde el provider ANTES de cualquier await
    final companyId = Provider.of<CompanyIdProvider>(
      context,
      listen: false,
    ).companyId;

    debugPrint('CreatePilotScreen - companyId: $companyId');

    // Cachear helpers basados en context ANTES del await
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (companyId == null) {
      // Si no hay companyId, mostramos un error
      messenger.showSnackBar(
        const SnackBar(content: Text('No se encontró el companyId')),
      );
      return;
    }

    try {
      // Aseguramos que se pase el companyId al crear el piloto
      await _userService.createUser(
        name: _nameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        roleId: 3, // Rol Pilot
        companyId: companyId, // Se pasa el companyId del provider
      );

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(content: Text('Piloto creado exitosamente')),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text('❌ Error al crear el piloto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Pilot')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required Field' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required Field' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required Field' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required Field' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required Field' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createUser,
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
