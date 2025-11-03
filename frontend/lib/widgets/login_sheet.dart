import 'package:flutter/material.dart';
import 'package:frontend/screens/homepage_admin.dart';
import 'package:frontend/screens/homepage_admin_company.dart';
import 'package:frontend/screens/homepage_pilot.dart';
import 'package:frontend/screens/homepage_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../services/token_storage.dart';
import 'package:frontend/widgets/forgot_password_sheet.dart';

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

  Uri _u(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<LoginResult> _loginUser(String email, String password) async {
    try {
      // 1️⃣ Login
      final loginRes = await http.post(
        _u('/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Si falla login, distinguir cuenta no verificada vs credenciales
      if (loginRes.statusCode != 200) {
        String msg = '';
        try {
          final body = jsonDecode(loginRes.body);
          if (body is Map && body['message'] is String) {
            msg = (body['message'] as String).toLowerCase();
          }
        } catch (_) {}

        final unverified =
            (loginRes.statusCode == 401 || loginRes.statusCode == 403) &&
            (msg.contains('no ha sido verificada') ||
                msg.contains('no verificada') ||
                msg.contains('not verified') ||
                msg.contains('verify your email'));

        return unverified ? LoginResult.unverified : LoginResult.invalid;
      }

      // 2️⃣ Extraer tokens
      final loginData = jsonDecode(loginRes.body) as Map<String, dynamic>;
      final token = (loginData['token'] ?? loginData['Token']) as String? ?? '';
      final refreshToken =
          (loginData['refreshToken'] ?? loginData['RefreshToken']) as String? ??
          '';
      if (token.isEmpty) return LoginResult.invalid;

      await TokenStorage.saveTokens(token, refreshToken);

      // 3️⃣ Obtener perfil (para obtener rol, companyId, etc.)
      final meRes = await http.get(
        _u('/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (meRes.statusCode != 200) {
        return LoginResult.invalid;
      }

      final userData = jsonDecode(meRes.body) as Map<String, dynamic>;

      // 4️⃣ Resolver rol y roleId
      String roleName = '';
      int? roleId;

      if (userData['role'] is String) {
        roleName = (userData['role'] as String).toLowerCase();
      } else if (userData['role'] is Map) {
        final r = userData['role'] as Map;
        if (r['name'] is String) roleName = (r['name'] as String).toLowerCase();
        if (r['id'] is int) roleId = r['id'] as int;
      }

      if (roleId == null && userData['roleId'] is int) {
        roleId = userData['roleId'] as int;
      }

      // Guardar companyId (solo si viene)
      int? companyId;
      if (userData['companyId'] is int) {
        companyId = userData['companyId'];
        await TokenStorage.saveCompanyId(companyId);
      } else {
        await TokenStorage.saveCompanyId(null);
      }

      // Guardar companyName (solo si viene)
      if (userData['companyName'] is String) {
        await TokenStorage.saveCompanyName(userData['companyName']);
      } else {
        await TokenStorage.saveCompanyName(
          '',
        ); // Si no está presente, podemos guardar un valor vacío
      }

      // 6Navegación según rol
      if (context.mounted) {
        Navigator.of(context).pop(); // Cierra el BottomSheet

        Future.delayed(const Duration(milliseconds: 150), () {
          final nav = Navigator.of(context, rootNavigator: true);

          if (roleName == 'admin' || roleId == 1) {
            nav.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePageAdmin()),
              (route) => false,
            );
          } else if (roleName == 'companyadmin' || roleId == 2) {
            // ✅ Pasamos el companyId al home del admin de compañía
            if (companyId == null) {
              // fallback: si no viene el companyId, lo tratamos como error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se encontró la empresa asignada'),
                ),
              );
              return;
            }

            nav.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => HomePageAdminCompany(companyId: companyId!),
              ),
              (route) => false,
            );
          } else if (roleName == 'pilot' || roleId == 3) {
            nav.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePagePilot()),
              (route) => false,
            );
          } else {
            nav.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePageScreen()),
              (route) => false,
            );
          }
        });
      }

      return LoginResult.success;
    } catch (e) {
      print('❗ Connection/Parsing error: $e');
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
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) => const ForgotPasswordSheet(),
                        );
                      },
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
