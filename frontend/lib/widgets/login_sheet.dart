import 'package:flutter/material.dart';

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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: integrar auth real
                            Navigator.of(context).pop(); // cerrar sheet
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
