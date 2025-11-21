import 'package:flutter/material.dart';
import 'package:frontend/models/company_model.dart';
import 'package:frontend/services/company_service.dart';

class EditCompanyScreen extends StatefulWidget {
  final CompanyModel company;

  const EditCompanyScreen({super.key, required this.company});

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyService = CompanyService();

  // Controladores base
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _discountController;

  // Nuevos controladores opcionales
  late TextEditingController _domesticWaitHourController;
  late TextEditingController _internationalWaitHourController;
  late TextEditingController _domesticOvernightController;
  late TextEditingController _internationalOvernightController;
  late TextEditingController _airportTaxController;
  late TextEditingController _handlingController;

  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.company;

    // Inicializar controladores con datos existentes
    _nameController = TextEditingController(text: c.name);
    _emailController = TextEditingController(text: c.email ?? '');
    _phoneController = TextEditingController(text: c.phoneNumber ?? '');
    _addressController = TextEditingController(text: c.address ?? '');
    _discountController = TextEditingController(
      text: c.emptyLegDiscount.toString(),
    );

    // Nuevos campos opcionales
    _domesticWaitHourController = TextEditingController(
      text: c.domesticWaitHourCost?.toString() ?? '',
    );
    _internationalWaitHourController = TextEditingController(
      text: c.internationalWaitHourCost?.toString() ?? '',
    );
    _domesticOvernightController = TextEditingController(
      text: c.domesticOvernightCost?.toString() ?? '',
    );
    _internationalOvernightController = TextEditingController(
      text: c.internationalOvernightCost?.toString() ?? '',
    );
    _airportTaxController = TextEditingController(
      text: c.airportTaxPerPassenger?.toString() ?? '',
    );
    _handlingController = TextEditingController(
      text: c.handlingPerPassenger?.toString() ?? '',
    );

    _isActive = c.isActive;
  }

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

  // ===========================================================
  // Actualizar empresa
  // ===========================================================
  Future<void> _updateCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _companyService.updateCompany(
        id: widget.company.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        emptyLegDiscount:
            double.tryParse(_discountController.text.trim()) ?? 0.5,
        isActive: _isActive,

        // 💰 Nuevos campos opcionales
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Company updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error updating company: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===========================================================
  // UI
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Company'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _buildField(
                'Company Name',
                _nameController,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter company name' : null,
              ),
              _buildField(
                'Email',
                _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              _buildField(
                'Phone Number',
                _phoneController,
                keyboardType: TextInputType.phone,
              ),
              _buildField('Address', _addressController),
              _buildField(
                'Empty Leg Discount (0.0 - 1.0)',
                _discountController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val < 0 || val > 1) {
                    return 'Enter a valid discount between 0 and 1';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              const Text(
                'Optional Rates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _buildOptionalField(
                'Domestic Wait Hour Cost',
                _domesticWaitHourController,
              ),
              _buildOptionalField(
                'International Wait Hour Cost',
                _internationalWaitHourController,
              ),
              _buildOptionalField(
                'Domestic Overnight Cost',
                _domesticOvernightController,
              ),
              _buildOptionalField(
                'International Overnight Cost',
                _internationalOvernightController,
              ),
              _buildOptionalField(
                'Airport Tax per Passenger',
                _airportTaxController,
              ),
              _buildOptionalField(
                'Handling per Passenger',
                _handlingController,
              ),

              const SizedBox(height: 24),

              // Switch para activar/desactivar
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                activeThumbColor: Colors.green,
                onChanged: (value) async {
                  // Usar BuildContext ANTES de cualquier await
                  final messenger = ScaffoldMessenger.of(context);
                  final companyId = widget.company.id;

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(
                        value ? 'Reactivate Company' : 'Deactivate Company',
                      ),
                      content: Text(
                        value
                            ? 'Do you want to reactivate this company?'
                            : 'Are you sure you want to deactivate this company?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    if (!mounted) {
                      return;
                    }

                    setState(() => _isLoading = true);

                    try {
                      if (value) {
                        await _companyService.reactivateCompany(companyId);
                      } else {
                        await _companyService.deactivateCompany(companyId);
                      }

                      if (!mounted) {
                        return;
                      }

                      setState(() => _isActive = value);

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? '✅ Company reactivated successfully'
                                : '⚠️ Company deactivated successfully',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) {
                        return;
                      }

                      messenger.showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  }
                },
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : _updateCompany,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // Widgets reutilizables
  // ===========================================================
  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildOptionalField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '$label (optional)',
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          if (v != null && v.isNotEmpty) {
            final val = double.tryParse(v);
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
