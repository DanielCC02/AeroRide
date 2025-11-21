import 'package:flutter/material.dart';
import 'package:frontend/services/company_service.dart';
import 'package:frontend/models/company_model.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores básicos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _discountController = TextEditingController(text: "0.5");

  // Nuevos controladores opcionales
  final _domesticWaitHourController = TextEditingController();
  final _internationalWaitHourController = TextEditingController();
  final _domesticOvernightController = TextEditingController();
  final _internationalOvernightController = TextEditingController();
  final _airportTaxController = TextEditingController();
  final _handlingController = TextEditingController();

  bool _isLoading = false;
  final CompanyService _companyService = CompanyService();

  // =============================================================
  // Crear empresa
  // =============================================================
  Future<void> _createCompany() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Usar BuildContext ANTES de cualquier await
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final CompanyModel newCompany = await _companyService.createCompany(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        emptyLegDiscount:
            double.tryParse(_discountController.text.trim()) ?? 0.5,
        // Campos opcionales
        domesticWaitHourCost: double.tryParse(
          _domesticWaitHourController.text.trim(),
        ),
        internationalWaitHourCost: double.tryParse(
          _internationalWaitHourController.text.trim(),
        ),
        domesticOvernightCost: double.tryParse(
          _domesticOvernightController.text.trim(),
        ),
        internationalOvernightCost: double.tryParse(
          _internationalOvernightController.text.trim(),
        ),
        airportTaxPerPassenger: double.tryParse(
          _airportTaxController.text.trim(),
        ),
        handlingPerPassenger: double.tryParse(_handlingController.text.trim()),
      );

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text('✅ Empresa creada: ${newCompany.name}')),
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text('❌ Error al crear empresa: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // =============================================================
  // Liberar controladores
  // =============================================================
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _discountController.dispose();
    _domesticWaitHourController.dispose();
    _internationalWaitHourController.dispose();
    _domesticOvernightController.dispose();
    _internationalOvernightController.dispose();
    _airportTaxController.dispose();
    _handlingController.dispose();
    super.dispose();
  }

  // =============================================================
  // UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Company'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Company Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _buildTextField(
                label: 'Company Name',
                controller: _nameController,
                validatorMsg: 'Enter company name',
              ),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validatorMsg: 'Enter a valid email',
              ),
              _buildTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validatorMsg: 'Enter phone number',
              ),
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                validatorMsg: 'Enter address',
              ),
              _buildTextField(
                label: 'Empty Leg Discount (0 - 1)',
                controller: _discountController,
                keyboardType: TextInputType.number,
                validatorMsg: 'Enter discount (e.g., 0.5)',
              ),

              const SizedBox(height: 24),
              const Text(
                'Optional Rates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _buildOptionalField(
                label: 'Domestic Wait Hour Cost',
                controller: _domesticWaitHourController,
              ),
              _buildOptionalField(
                label: 'International Wait Hour Cost',
                controller: _internationalWaitHourController,
              ),
              _buildOptionalField(
                label: 'Domestic Overnight Cost',
                controller: _domesticOvernightController,
              ),
              _buildOptionalField(
                label: 'International Overnight Cost',
                controller: _internationalOvernightController,
              ),
              _buildOptionalField(
                label: 'Airport Tax per Passenger',
                controller: _airportTaxController,
              ),
              _buildOptionalField(
                label: 'Handling per Passenger',
                controller: _handlingController,
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _createCompany,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_business),
                label: Text(_isLoading ? 'Creating...' : 'Create Company'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // Campos reutilizables
  // =============================================================

  /// Campo obligatorio
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String validatorMsg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return validatorMsg;
          }
          return null;
        },
      ),
    );
  }

  /// Campo opcional para valores numéricos
  Widget _buildOptionalField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '$label (optional)',
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final val = double.tryParse(value);
            if (val == null || val < 0) {
              return 'Enter a valid positive number';
            }
          }
          return null;
        },
      ),
    );
  }
}
