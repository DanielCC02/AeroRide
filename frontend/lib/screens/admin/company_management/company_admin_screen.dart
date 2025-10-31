import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/admin/company_management/create_admin_screen.dart';
import 'package:frontend/services/user_service.dart';

class CompanyAdminsScreen extends StatefulWidget {
  final int companyId;

  const CompanyAdminsScreen({super.key, required this.companyId});

  @override
  State<CompanyAdminsScreen> createState() => _CompanyAdminsScreenState();
}

class _CompanyAdminsScreenState extends State<CompanyAdminsScreen> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _adminsFuture;

  @override
  void initState() {
    super.initState();
    _adminsFuture = _userService.getCompanyAdmins(widget.companyId);
  }

  Future<void> _refreshAdmins() async {
    setState(() {
      _adminsFuture = _userService.getCompanyAdmins(widget.companyId);
    });
  }

  Future<void> _goToCreateAdmin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAdminScreen(companyId: widget.companyId),
      ),
    );
    await _refreshAdmins(); // 🔁 Refresca la lista al volver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company administrators'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _adminsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '⚠️ Error al cargar administradores:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshAdmins,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final admins = snapshot.data ?? [];

          if (admins.isEmpty) {
            return const Center(
              child: Text('There are no registered administrators for this company.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAdmins,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: admins.length,
              itemBuilder: (context, index) {
                final admin = admins[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.shade100,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('${admin.name} ${admin.lastName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(admin.email),
                        Text(admin.phoneNumber),
                        Text(
                          admin.isActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: admin.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCreateAdmin,
        icon: const Icon(Icons.add),
        label: const Text('Create Administrator'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
