import 'package:flutter/material.dart';

/// Panel principal de acciones para el administrador.
///
/// Muestra una lista de botones con las principales opciones
/// de gestión del sistema (por ahora sin funcionalidad).
class AdminActionsPanel extends StatelessWidget {
  const AdminActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de acciones que tendrá el panel
    final List<Map<String, dynamic>> actions = [
      {'label': 'Company Management', 'icon': Icons.business},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Generar botones a partir de la lista
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

                  if (label == 'Company Management') {
                    Navigator.pushNamed(context, '/admin/company_management');
                    return;
                  }

                  // 🔹 Si todavía no hay implementación para esa acción
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${action['label']} (coming soon)'),
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
