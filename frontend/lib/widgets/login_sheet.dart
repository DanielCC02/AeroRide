import 'package:flutter/material.dart';
import 'package:frontend/screens/homepage_admin.dart';
import 'package:frontend/screens/homepage_pilot.dart';
import 'package:frontend/screens/homepage_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../services/token_storage.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

enum LoginResult { success, unverified, invalid }

class _LoginSheetState extends State<LoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  Future<LoginResult> _loginUser(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // ❌ Error de login
      if (response.statusCode != 200) {
        String msg = '';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] is String) {
            msg = (body['message'] as String).toLowerCase();
          }
        } catch (_) {}

        // Detectar "cuenta no verificada" (ES/EN) y típicos códigos 401/403
        final isUnverified =
            (response.statusCode == 401 || response.statusCode == 403) &&
            (msg.contains('no ha sido verificada') ||
                msg.contains('no verificada') ||
                msg.contains('not verified') ||
                msg.contains('verify your email'));

        return isUnverified ? LoginResult.unverified : LoginResult.invalid;
      }

      // ✅ Login OK → guardar tokens
      final data = jsonDecode(response.body);
      final token = data['token'] ?? '';
      final refreshToken = data['refreshToken'] ?? '';
      if (token.isEmpty) return LoginResult.invalid;

      await TokenStorage.saveTokens(token, refreshToken);

      // 🔎 Obtener perfil (fallback /api/users/me → /users/me)
      Future<http.Response> _getMe(String path) => http.get(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      http.Response meResponse = await _getMe('/api/users/me');
      if (meResponse.statusCode == 404 || meResponse.statusCode == 405) {
        meResponse = await _getMe('/users/me');
      }

      if (meResponse.statusCode == 200) {
        final userData = jsonDecode(meResponse.body);
        final roleName = (userData['role'] ?? '').toString().toLowerCase();

        if (context.mounted) {
          Navigator.of(context).pop(); // Cierra el BottomSheet

          Future.delayed(const Duration(milliseconds: 200), () {
            final navigator = Navigator.of(context, rootNavigator: true);

            if (roleName == 'admin') {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePageAdmin()),
                (route) => false,
              );
            } else if (roleName == 'pilot') {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePagePilot()),
                (route) => false,
              );
            } else {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePageScreen()),
                (route) => false,
              );
            }
          });
        }
        return LoginResult.success;
      } else {
        return LoginResult.invalid;
      }
    } catch (e) {
      // ignore: avoid_print
      print('❗ Connection error: $e');
      return LoginResult.invalid;
    }
  }

  Future<void> _showDialog({
    required String title,
    required String message,
  }) async {
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              const Text(
                'Login',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Min 6 chars' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final result = await _loginUser(
                              _email.text.trim(),
                              _password.text.trim(),
                            );

                            if (!mounted) return;

                            if (result == LoginResult.unverified) {
                              await _showDialog(
                                title: 'Account not verified',
                                message:
                                    'Please verify your email to continue. We just sent you a new confirmation email.',
                              );
                            } else if (result == LoginResult.invalid) {
                              await _showDialog(
                                title: 'Login failed',
                                message: 'Incorrect email or password.',
                              );
                            }
                            // success → navegación ya se hace dentro de _loginUser
                          }
                        },
                        child: const Text('Log in'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {}, // TODO: forgot password
                      child: const Text('Forgot password?'),
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
