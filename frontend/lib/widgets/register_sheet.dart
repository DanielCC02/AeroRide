import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../services/auth_service.dart';
import '../screens/legal_document_screen.dart';

class RegisterSheet extends StatefulWidget {
  const RegisterSheet({super.key});

  @override
  State<RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<RegisterSheet> {
  // ======================================================
  // LEGAL DOCS URLS (Azure Blob)
  // ======================================================
  static const String _termsUrl =
      'https://aeroridetest.blob.core.windows.net/legal/terms-of-use-2026-01.pdf';

  static const String _privacyUrl =
      'https://aeroridetest.blob.core.windows.net/legal/privacy-policy-2026-01.pdf';

  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
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

  // ======================================================
  // OPEN LEGAL DOC (FORCED SCROLL)
  // ======================================================
  Future<void> _openLegalDoc({
    required String title,
    required String url,
    required VoidCallback onAccepted,
  }) async {
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: title,
          url: url,
        ),
      ),
    );

    if (accepted == true) {
      onAccepted();
    }
  }

  // ======================================================
  // SUBMIT
  // ======================================================
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

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Action required'),
          content: const Text(
            'You must accept both the Terms of Use and the Privacy Notice in order to create an account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
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
        termsOfUse: _agreeTerms,
        privacyNotice: _agreePrivacy,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Account created!'),
          content: const Text(
            'Check your email to verify your account. It may be in your spam folder.',
          ),
          actions: [
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

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {

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

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixText: _phoneCountryCode != null
                            ? '+$_phoneCountryCode '
                            : '',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Confirm password'),
                    ),

                    const SizedBox(height: 16),

                    // TERMS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(value: _agreeTerms, onChanged: null),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Wrap(
                              children: [
                                const Text('I agree to the '),
                                GestureDetector(
                                  onTap: () {
                                    _openLegalDoc(
                                      title: 'Terms of Use',
                                      url: _termsUrl,
                                      onAccepted: () {
                                        setState(() => _agreeTerms = true);
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Terms of Use',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // PRIVACY
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(value: _agreePrivacy, onChanged: null),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Wrap(
                              children: [
                                const Text('I agree to the '),
                                GestureDetector(
                                  onTap: () {
                                    _openLegalDoc(
                                      title: 'Privacy Notice',
                                      url: _privacyUrl,
                                      onAccepted: () {
                                        setState(() => _agreePrivacy = true);
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Privacy Notice',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator()
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
