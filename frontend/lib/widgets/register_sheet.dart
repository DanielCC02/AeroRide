import 'package:flutter/material.dart';
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
  final _phone = TextEditingController(text: '+506 ');
  final _password = TextEditingController();
  final _confirm = TextEditingController();

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
    setState(() => _fieldErrors = {});
    if (!_formKey.currentState!.validate()) return;

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
      // Registro (no usamos el mensaje retornado)
      await _auth.register(
        name: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phoneNumber: _phone.text.trim(),
      );

      if (!mounted) return;
      // ✅ Diálogo corto en inglés con botones
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Account created!'),
          content: const Text(
            'Check your email to verify your account. It may be in your spam folder.',
          ),
          actions: [
            // Cierra solo el diálogo
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
            // Cierra diálogo + sheet → vuelve al Welcome
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // close dialog
                Navigator.of(context).pop(); // close bottom sheet
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      );

      // Nota: ya no hacemos pop() aquí porque el botón "Go to Home"
      // lo maneja dentro del diálogo para evitar doble-pop.
    } on AuthServiceException catch (e) {
      setState(() => _fieldErrors = e.fieldErrors ?? {});
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
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
          // Header
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
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: _errorFor('email'),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Invalid email'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        errorText: _errorFor('phonenumber'),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
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
