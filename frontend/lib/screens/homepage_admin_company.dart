import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar el provider
import '../services/token_storage.dart';
import 'welcome_screen.dart';
import '../widgets/admin_company_actions_panel.dart';
import '../providers/company_id_provider.dart'; // Importar el provider que creamos

class HomePageAdminCompany extends StatelessWidget {
  const HomePageAdminCompany({super.key});

  @override
  Widget build(BuildContext context) {
    // Acceder al companyId desde el provider
    final companyId = Provider.of<CompanyIdProvider>(context).companyId;

    // Agregamos un print para verificar el valor de companyId
    debugPrint('HomePageAdminCompany - companyId: $companyId');

    if (companyId == null) {
      // Si no se encuentra el companyId, redirigir al usuario a la pantalla de bienvenida
      return const WelcomeScreen();
    }

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
          child: AdminCompanyActionsPanel(),
        ),
      ),
    );
  }
}
