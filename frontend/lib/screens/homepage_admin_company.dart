import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import 'welcome_screen.dart';
import '../widgets/admin_company_actions_panel.dart';

class HomePageAdminCompany extends StatelessWidget {
  const HomePageAdminCompany({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Company'),
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
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: AdminCompanyActionsPanel(),
        ),
      ),
    );
  }
}
