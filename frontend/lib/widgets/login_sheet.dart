import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/homepage_screen.dart';
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

      // 🧠 Tu backend devuelve: token y refreshToken
      final token = data['token'] ?? '';
      final refreshToken = data['refreshToken'] ?? '';

      if (token.isNotEmpty) {
        await TokenStorage.saveTokens(token, refreshToken);
        print('✅ Login exitoso: token guardado correctamente');
      } else {
        print('⚠️ Login exitoso pero el token vino vacío');
      }

      return true;
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

                            if (success) {
                              // ✅ Cerrar el sheet
                              if (mounted) Navigator.pop(context);

                              // ✅ Ir al HomePageScreen
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomePageScreen(),
                                  ),
                                );
                              }
                            } else {
                              // ❌ Mostrar error si el login falla
                              if (mounted) {
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
