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

class _LoginSheetState extends State<LoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  Future<bool> _loginUser(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? '';
        final refreshToken = data['refreshToken'] ?? '';

        if (token.isEmpty) return false;

        await TokenStorage.saveTokens(token, refreshToken);

        // 🔹 Obtener perfil de usuario autenticado
        final meUrl = Uri.parse('${ApiConfig.baseUrl}/api/users/me');
        final meResponse = await http.get(
          meUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (meResponse.statusCode == 200) {
          final userData = jsonDecode(meResponse.body);
          final roleName = (userData['role'] ?? '').toString().toLowerCase();

          print('👤 Usuario autenticado con rol: $roleName');

          if (context.mounted) {
            Navigator.of(context).pop(); // Cierra el BottomSheet

            Future.delayed(const Duration(milliseconds: 200), () {
              // 🔹 Este Navigator opera sobre el árbol raíz del MaterialApp
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
          return true;
        } else {
          print('⚠️ No se pudo obtener perfil de usuario: ${meResponse.body}');
          return false;
        }
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❗ Error de conexión: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos AnimatedPadding para levantar el contenido cuando sale el teclado
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        children: [
          // Header con back + título
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

          // El resto debe poder hacer scroll si es necesario
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
                            final success = await _loginUser(
                              _email.text.trim(),
                              _password.text.trim(),
                            );

                            if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Correo o contraseña incorrectos',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
