import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/admin/company_management/edit_company_admin_screen.dart';
import 'package:frontend/services/user_service.dart';

/// Pantalla de detalle del administrador de compañía.
/// Muestra la información del usuario y permite editarla.
class CompanyAdminDetailScreen extends StatefulWidget {
  final int adminId;

  const CompanyAdminDetailScreen({super.key, required this.adminId});

  @override
  State<CompanyAdminDetailScreen> createState() =>
      _CompanyAdminDetailScreenState();
}

class _CompanyAdminDetailScreenState extends State<CompanyAdminDetailScreen> {
  final UserService _userService = UserService();
  late Future<UserModel> _adminFuture;

  @override
  void initState() {
    super.initState();
    _adminFuture = _userService.getCompanyAdminById(widget.adminId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _adminFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Company Admin Details')),
            body: Center(
              child: Text(
                '⚠️ Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Admin not found.')),
          );
        }

        final admin = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(admin.name),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, true); // 🔁 refrescar lista al volver
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit admin info',
                onPressed: () async {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCompanyAdminScreen(admin: admin),
                    ),
                  );

                  if (refresh == true && context.mounted) {
                    setState(() {
                      _adminFuture =
                          _userService.getCompanyAdminById(widget.adminId);
                    });
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.person, size: 80, color: Colors.grey),
                  ), 

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // 🧾 Información general
                _buildSectionTitle('General Information'),
                _buildDetailRow('Name', admin.name),
                _buildDetailRow('Last Name', admin.lastName),
                _buildDetailRow('Email', admin.email),
                _buildDetailRow('Phone', admin.phoneNumber),
                const SizedBox(height: 20),

                // 🏢 Compañía
                _buildSectionTitle('Company Information'),
                _buildDetailRow('Company', admin.companyName ?? '—'),
                const SizedBox(height: 20),

                // ⚙️ Estado
                _buildSectionTitle('Status'),
                _buildDetailRow(
                  'Active',
                  admin.isActive ? 'Yes' : 'No',
                  color: admin.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔹 Sección de título
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 🔹 Fila de detalle
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
