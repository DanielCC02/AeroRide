import 'package:flutter/material.dart';
import '../widgets/login_sheet.dart';
import '../widgets/register_sheet.dart';
import '../services/token_storage.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Observa el ciclo de vida de la app (para limpiar al volver a primer plano)
    WidgetsBinding.instance.addObserver(this);
    // Limpia cualquier sesión/tokens apenas entras a esta pantalla
    _resetSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Resetea sesión (borra tokens persistidos).
  Future<void> _resetSession() async {
    await TokenStorage.clearTokens();
  }

  /// Cuando la app vuelve a primer plano (p.ej., tras un cierre inesperado
  /// y reabrir en esta pantalla), vuelve a limpiar tokens para evitar estados viejos.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(''), backgroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          // 👈 permite scroll si el contenido no cabe (evita overflow)
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Logo
              Image.asset(
                'assets/images/logo.jpg',
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),

              // Tarjeta central
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'You are not logged in',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please log in or create account',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),

                      // Create account (rojo estático)
                      ElevatedButton(
                        onPressed: () => _openRegisterSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3A3A), // rojo fijo
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Create account'),
                      ),
                      const SizedBox(height: 10),

                      // Log in (outlined)
                      OutlinedButton(
                        onPressed: () => _openLoginSheet(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Log in'),
                      ),
                      const SizedBox(height: 16),

                      // Privacy
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Privacy Settings',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By using Aerocaribe’s service, you agree to our Terms & Conditions and applicable Privacy Policy',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40), // Espacio final para estética
            ],
          ),
        ),
      ),
    );
  }

  // ======= SHEETS A PANTALLA COMPLETA + SAFE AREA =======
  void _openLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // usa toda la altura
      useSafeArea: true, // respeta notch/barras
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (_) {
        return const SizedBox.expand(
          // ocupa toda la pantalla
          child: LoginSheet(),
        );
      },
    );
  }

  void _openRegisterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (_) {
        return const SizedBox.expand(child: RegisterSheet());
      },
    );
  }
}
