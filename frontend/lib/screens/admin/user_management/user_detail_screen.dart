import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import 'edit_user_screen.dart';

/// Pantalla que muestra la información detallada de un usuario.
/// Solo accesible para administradores.
class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
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
            appBar: AppBar(title: const Text('User Details')),
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
            title: const Text('User Details'),
            centerTitle: true,
            // 👇 NO pongas automaticallyImplyLeading: false
            // porque eso elimina el botón de retroceso
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditUserScreen(user: user),
                    ),
                  );

                  if (refresh == true && context.mounted) {
                    // ✅ Cerrar también esta pantalla y devolver “true”
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
                      backgroundColor: user.isActive
                          ? Colors.green
                          : Colors.grey,
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

                // 🔹 Datos detallados del usuario
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

                const SizedBox(height: 30),

                // 🔹 Botón para desactivar usuario
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.isActive
                        ? Colors.redAccent
                        : Colors.green,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: Icon(user.isActive ? Icons.block : Icons.refresh),
                  label: Text(
                    user.isActive ? 'Deactivate User' : 'Reactivate User',
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          user.isActive
                              ? 'Confirm Deactivation'
                              : 'Confirm Reactivation',
                        ),
                        content: Text(
                          user.isActive
                              ? 'Are you sure you want to deactivate this user?'
                              : 'Are you sure you want to reactivate this user?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: user.isActive
                                  ? Colors.redAccent
                                  : Colors.green,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      try {
                        if (user.isActive) {
                          await _userService.deactivateUser(user.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ Usuario desactivado correctamente',
                              ),
                            ),
                          );
                        } else {
                          // ♻️ Reactivar usuario
                          await _userService.reactivateUser(user.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ Usuario reactivado correctamente',
                              ),
                            ),
                          );
                        }
                        // Regresar al listado y actualizar
                        Navigator.pop(context, true);
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
                      }
                    }
                  },
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
