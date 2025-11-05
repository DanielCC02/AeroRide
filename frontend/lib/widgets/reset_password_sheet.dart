import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordSheet extends StatefulWidget {
  const ResetPasswordSheet({super.key});

  @override
  State<ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<ResetPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();
  final _pwd1 = TextEditingController();
  final _pwd2 = TextEditingController();

  bool _saving = false;
  bool _ob1 = true;
  bool _ob2 = true;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _pwd1.dispose();
    _pwd2.dispose();
    super.dispose();
  }

  Future<void> _showDialog(String title, String message) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _grabHandle() => Center(
    child: Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6, // 60% de la altura
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                viewInsets.bottom + 16, // evita que el teclado tape
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _grabHandle(),
                    const Text(
                      'Reset password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tokenCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Token',
                        hintText: 'Paste the token you received by email',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Paste the token'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwd1,
                      obscureText: _ob1,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _ob1 = !_ob1),
                          icon: Icon(
                            _ob1 ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Min 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwd2,
                      obscureText: _ob2,
                      decoration: InputDecoration(
                        labelText: 'Confirm new password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _ob2 = !_ob2),
                          icon: Icon(
                            _ob2 ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'Min 6 characters';
                        }
                        if (v != _pwd1.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                setState(() => _saving = true);
                                try {
                                  await AuthService().resetPassword(
                                    token: _tokenCtrl.text.trim(),
                                    newPassword: _pwd1.text,
                                  );
                                  if (!mounted) return;
                                  await _showDialog(
                                    'Success',
                                    'Password updated. You can now sign in.',
                                  );
                                  if (!mounted) return;

                                  // Cierra todos los sheets y vuelve a la raíz (Welcome)
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).popUntil((route) => route.isFirst);
                                } on AuthServiceException catch (e) {
                                  if (!mounted) return;
                                  await _showDialog('Error', e.message);
                                } catch (_) {
                                  if (!mounted) return;
                                  await _showDialog(
                                    'Error',
                                    'Unexpected error. Please try again.',
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _saving = false);
                                  }
                                }
                              },
                        child: Text(_saving ? 'Updating…' : 'Update password'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
