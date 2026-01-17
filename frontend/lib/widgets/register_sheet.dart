import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../services/auth_service.dart';

class RegisterSheet extends StatefulWidget {
  const RegisterSheet({super.key});

  @override
  State<RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<RegisterSheet> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController(); // SOLO número
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  // Nacionalidad / teléfono
  String? _nationalityName;
  String? _phoneCountryCode;
  bool _showNationalityError = false;

  bool _isLoading = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  final _auth = AuthService();
  Map<String, List<String>> _fieldErrors = {};

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _errorFor(String field) {
    final errs = _fieldErrors[field.toLowerCase()];
    if (errs == null || errs.isEmpty) return null;
    return errs.join('\n');
  }

  Future<void> _submit() async {
    setState(() {
      _fieldErrors = {};
      _showNationalityError = _nationalityName == null;
    });

    if (!_formKey.currentState!.validate() || _nationalityName == null) {
      return;
    }

    if (!_agreeTerms || !_agreePrivacy) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You must accept the Terms of Use and the Privacy Notice.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.register(
        name: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phoneNumber: '+$_phoneCountryCode${_phone.text.trim()}',
        country: _nationalityName!,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Account created!'),
          content: const Text(
            'Check your email to verify your account. It may be in your spam folder.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      );
    } on AuthServiceException catch (e) {
      setState(() => _fieldErrors = e.fieldErrors ?? {});
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.92,
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // FIRST NAME
                    TextFormField(
                      controller: _firstName,
                      decoration: InputDecoration(
                        labelText: 'First name',
                        errorText: _errorFor('name'),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    // LAST NAME
                    TextFormField(
                      controller: _lastName,
                      decoration: InputDecoration(
                        labelText: 'Last name',
                        errorText: _errorFor('lastname'),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    // EMAIL
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: _errorFor('email'),
                      ),
                      validator: (v) =>
                          (v == null || !v.contains('@'))
                              ? 'Invalid email'
                              : null,
                    ),
                    const SizedBox(height: 12),

                    // NATIONALITY
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          showWorldWide: false,
                          onSelect: (Country c) {
                            setState(() {
                              _nationalityName = c.name;
                              _phoneCountryCode = c.phoneCode;
                              _showNationalityError = false;
                              _phone.clear();
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _showNationalityError
                                ? Colors.red
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_nationalityName != null)
                              Text(
                                '$_nationalityName (+$_phoneCountryCode)',
                                style: const TextStyle(fontSize: 16),
                              )
                            else
                              const Text(
                                'Select nationality',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            const Spacer(),
                            const Icon(Icons.flag),
                          ],
                        ),
                      ),
                    ),

                    if (_showNationalityError)
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Required',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // PHONE (sin hint)
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixText: _phoneCountryCode != null
                            ? '+$_phoneCountryCode '
                            : '',
                        errorText: _errorFor('phonenumber'),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                          return 'Only numbers allowed';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // PASSWORD
                    TextFormField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: _errorFor('password'),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.length < 8) {
                          return 'Min 8 characters';
                        }
                        final hasNum = RegExp(r'[0-9]').hasMatch(v);
                        final hasLet = RegExp(r'[A-Za-z]').hasMatch(v);
                        if (!hasNum || !hasLet) {
                          return 'Include letters and numbers';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _confirm,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                      ),
                      obscureText: true,
                      validator: (v) => v == null
                          ? 'Required'
                          : (v != _password.text
                              ? 'Passwords do not match'
                              : null),
                    ),

                    const SizedBox(height: 16),

                    // AGREEMENTS
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeTerms,
                          onChanged: (v) =>
                              setState(() => _agreeTerms = v ?? false),
                        ),
                        const Expanded(
                          child: Text('I agree to the Terms of Use'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreePrivacy,
                          onChanged: (v) =>
                              setState(() => _agreePrivacy = v ?? false),
                        ),
                        const Expanded(
                          child: Text('I agree to the Privacy Notice'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // SUBMIT
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
