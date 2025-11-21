import 'package:flutter/material.dart';
import 'package:frontend/screens/admin/company_management/create_company_screen.dart';
import 'package:frontend/screens/admin/company_management/company_detail_screen.dart';
import '../../../models/company_model.dart';
import '../../../services/company_service.dart';
import '../../../services/token_storage.dart';
import '../../welcome_screen.dart';

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  State<CompanyManagementScreen> createState() =>
      _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  final CompanyService _companyService = CompanyService();
  late Future<List<CompanyModel>> _companiesFuture;

  @override
  void initState() {
    super.initState();
    _companiesFuture = _companyService.getAllCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Management'),
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
      body: FutureBuilder<List<CompanyModel>>(
        future: _companiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '⚠️ Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No companies found.'));
          }

          final companies = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: companies.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final company = companies[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      company.isActive ? Colors.green : Colors.grey,
                  child: Text(
                    company.name.isNotEmpty
                        ? company.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(company.name),
                subtitle: Text(
                  '${company.email ?? 'No email'} • ${company.phoneNumber ?? 'No phone number'}',
                ),
                trailing: Icon(
                  company.isActive ? Icons.check_circle : Icons.block,
                  color: company.isActive ? Colors.green : Colors.red,
                ),
                onTap: () async {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CompanyDetailScreen(companyId: company.id),
                    ),
                  );

                  // 🔁 Si se edita o elimina, recargamos la lista
                  if (refresh == true && context.mounted) {
                    setState(() {
                      _companiesFuture = _companyService.getAllCompanies();
                    });
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add_business),
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCompanyScreen()),
          );

          // 🔹 Si se creó una nueva empresa, recargamos la lista
          if (refresh == true && mounted) {
            setState(() {
              _companiesFuture = _companyService.getAllCompanies();
            });
          }
        },
      ),
    );
  }
}
