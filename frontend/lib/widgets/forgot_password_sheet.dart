import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'reset_password_sheet.dart';

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
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
                      'Forgot password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter your email';
                        }
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _sending
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                setState(() => _sending = true);
                                try {
                                  final ok = await AuthService()
                                      .requestPasswordReset(_email.text.trim());
                                  if (!mounted) return;

                                  if (ok) {
                                    await _showDialog(
                                      'Email sent',
                                      'We sent you an email with instructions. Confirm it to get your token.',
                                    );
                                    if (!mounted) return;

                                    // Abrimos el sheet de Reset encima
                                    showModalBottomSheet(
                                      context: context,
                                      useRootNavigator: true,
                                      isScrollControlled: true,
                                      // showDragHandle: true, // (opcional si tu versión lo soporta)
                                      backgroundColor: Colors.transparent,
                                      builder: (_) =>
                                          const ResetPasswordSheet(),
                                    );
                                  } else {
                                    await _showDialog(
                                      'Error',
                                      'Could not send the email. Try again later.',
                                    );
                                  }
                                } on AuthServiceException catch (e) {
                                  if (!mounted) return;
                                  final msg =
                                      e.message ==
                                          'This email is not registered'
                                      ? 'This email is not registered'
                                      : e.message;
                                  await _showDialog('Warning', msg);
                                } catch (_) {
                                  if (!mounted) return;
                                  await _showDialog(
                                    'Error',
                                    'Unexpected error. Please try again.',
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _sending = false);
                                  }
                                }
                              },
                        child: Text(
                          _sending ? 'Sending…' : 'Send confirmation',
                        ),
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
