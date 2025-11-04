import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/admin/company_pilots/edit_pilot_screen.dart';
import 'package:frontend/services/user_service.dart';

/// Pantalla que muestra la información detallada de un piloto.
/// Solo accesible para administradores o administradores de compañía.
class PilotDetailScreen extends StatefulWidget {
  final int userId;

  const PilotDetailScreen({super.key, required this.userId});

  @override
  State<PilotDetailScreen> createState() => _PilotDetailScreenState();
}

class _PilotDetailScreenState extends State<PilotDetailScreen> {
  final UserService _userService = UserService();
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserById(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pilot Details')),
            body: Center(
              child: Text(
                '⚠️ Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('User not found.')));
        }

        // ✅ Usuario cargado correctamente
        final user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pilot Details'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Pilot',
                onPressed: () async {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPilotScreen(user: user),
                    ),
                  );

                  if (refresh == true && context.mounted) {
                    // ✅ Cerrar esta pantalla y devolver “true” al listado
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                // 🔹 Encabezado con avatar y nombre
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          user.isActive ? Colors.green : Colors.grey,
                      child: Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // 🔹 Datos detallados del piloto
                _buildDetailRow('Email', user.email),
                _buildDetailRow('Phone', user.phoneNumber),
                _buildDetailRow('Role', user.role),
                _buildDetailRow(
                  'Status',
                  user.isActive ? 'Active' : 'Inactive',
                  color: user.isActive ? Colors.green : Colors.red,
                ),
                _buildDetailRow('First Name', user.name),
                _buildDetailRow('Last Name', user.lastName),
                _buildDetailRow(
                  'Registered on',
                  user.registrationDate?.split('T').first ?? '-',
                ),
                _buildDetailRow(
                  'Terms of Use',
                  user.termsOfUse == true ? 'Accepted' : 'Not Accepted',
                ),
                _buildDetailRow(
                  'Privacy Notice',
                  user.privacyNotice == true ? 'Accepted' : 'Not Accepted',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔹 Widget auxiliar para mostrar cada fila de detalle (campo: valor)
  Widget _buildDetailRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: color ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
