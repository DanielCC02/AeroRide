import 'package:flutter/material.dart';

/// Panel principal de acciones para el administrador de compañía.
/// Muestra las principales opciones de gestión, filtradas por la empresa
/// a la que pertenece el administrador actual.
class AdminCompanyActionsPanel extends StatelessWidget {
  final int companyId; // ✅ Recibimos el ID de la compañía

  const AdminCompanyActionsPanel({
    super.key,
    required this.companyId, // ✅ Obligatorio
  });

  @override
  Widget build(BuildContext context) {
    // Lista de acciones disponibles
    final List<Map<String, dynamic>> actions = [
      {'label': 'See Calendar', 'icon': Icons.calendar_today},
      {'label': 'User Management', 'icon': Icons.people},
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

                  if (label == 'User Management') {
                    // ✅ Ejemplo: pasar el companyId a la pantalla de usuarios
                    Navigator.pushNamed(
                      context,
                      '/admin/users',
                      arguments: {'companyId': companyId},
                    );
                    return;
                  }

                  if (label == 'Fleet Management') {
                    Navigator.pushNamed(
                      context,
                      '/admin/fleet',
                      arguments: {'companyId': companyId}, // ✅ igual aquí
                    );
                    return;
                  }

                  if (label == 'Pilot Management') {
                    Navigator.pushNamed(
                      context,
                      '/admin/pilots',
                      arguments: {'companyId': companyId},
                    );
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
