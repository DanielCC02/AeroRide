import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Asegúrate de importar el provider
import '../providers/company_id_provider.dart'; // Importamos el provider que creamos

/// Panel principal de acciones para el administrador de compañía.
/// Muestra las principales opciones de gestión, filtradas por la empresa
/// a la que pertenece el administrador actual.
class AdminCompanyActionsPanel extends StatelessWidget {
  const AdminCompanyActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // Acceder al companyId desde el provider
    final companyId = Provider.of<CompanyIdProvider>(context).companyId;

    if (companyId == null) {
      // Si no hay companyId disponible, mostramos un error o redirigimos al usuario
      return const Center(
        child: Text('Company ID not found. Please log in again.'),
      );
    }

    // Lista de acciones disponibles
    final List<Map<String, dynamic>> actions = [
      {'label': 'See Calendar', 'icon': Icons.calendar_today},
      //{'label': 'User Management', 'icon': Icons.people},
      {'label': 'Fleet Management', 'icon': Icons.airplanemode_active},
      {'label': 'Pilot Management', 'icon': Icons.flight_takeoff},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // 🔹 Generar los botones dinámicamente
          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFFDC3A3A),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  final label = action['label'] as String;

                  // Usamos el companyId desde el Provider en lugar de pasar como argumento
                  /*if (label == 'User Management') {
                    Navigator.pushNamed(
                      context,
                      '/admin/users',
                    );
                    return;
                  }*/

                  if (label == 'See Calendar') {
                    Navigator.pushNamed(context, '/admin/flight-schedule');
                    return;
                  }

                  if (label == 'Fleet Management') {
                    Navigator.pushNamed(context, '/admin/fleet');
                    return;
                  }

                  if (label == 'Pilot Management') {
                    Navigator.pushNamed(context, '/admin/pilots');
                    return;
                  }

                  // 🔸 Acciones aún no implementadas
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${action['label']} for company $companyId (coming soon)',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(action['icon'] as IconData),
                label: Text(action['label'] as String),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
