import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import 'welcome_screen.dart';
import '../widgets/admin_company_actions_panel.dart';

class HomePageAdminCompany extends StatelessWidget {
  final int? companyId;

  const HomePageAdminCompany({
    super.key,
    this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: TokenStorage.getCompanyName(), // Obtenemos el nombre de la compañía
          builder: (context, snapshot) {
            String companyName = snapshot.data ?? 'My Company';

            return Text(companyName);
          },
        ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: AdminCompanyActionsPanel(
            companyId: companyId ?? 0, // Fallback para evitar null
          ),
        ),
      ),
    );
  }
}
