import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import 'welcome_screen.dart';

class HomePagePilot extends StatelessWidget {
  const HomePagePilot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilot Panel'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await TokenStorage.clearTokens();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false, // 🔹 borra todo el stack anterior
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('🛩️ Pilot View', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
