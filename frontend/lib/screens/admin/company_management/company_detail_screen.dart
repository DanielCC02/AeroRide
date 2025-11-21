import 'package:flutter/material.dart';
import 'package:frontend/models/company_model.dart';
import 'package:frontend/screens/admin/company_management/company_admin_screen.dart';
import 'package:frontend/screens/admin/company_management/edit_company_screen.dart';
import 'package:frontend/services/company_service.dart';

class CompanyDetailScreen extends StatefulWidget {
  final int companyId;

  const CompanyDetailScreen({super.key, required this.companyId});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final CompanyService _companyService = CompanyService();
  late Future<CompanyModel> _companyFuture;
  bool _hasUpdated = false; // Para saber si hubo cambios al editar

  @override
  void initState() {
    super.initState();
    _companyFuture = _companyService.getCompanyById(widget.companyId);
  }

  Future<void> _refreshCompany() async {
    setState(() {
      _companyFuture = _companyService.getCompanyById(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Evitamos que Flutter haga el pop automático: queremos controlar el resultado (_hasUpdated)
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Si ya se hizo pop por otra razón, no hacemos nada
        if (didPop) {
          return;
        }
        // Misma lógica que antes: devolver _hasUpdated al cerrar
        Navigator.pop(context, _hasUpdated);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Company Details'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _hasUpdated),
          ),
        ),
        body: FutureBuilder<CompanyModel>(
          future: _companyFuture,
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
                      '⚠️ Error al cargar la empresa:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshCompany,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No company data found.'));
            }

            final company = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refreshCompany,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      company.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(company.email ?? 'No email provided'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Teléfono
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(company.phoneNumber ?? 'No phone number'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 📍 Dirección
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(company.address ?? 'No address provided'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Descuento EmptyLeg
                    Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Empty Leg Discount: ${(company.emptyLegDiscount * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Fecha de creación
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Created at: ${company.createdAt.toLocal().toString().split(' ')[0]}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Estado
                    Row(
                      children: [
                        const Icon(Icons.power_settings_new, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          company.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: company.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Botón editar
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Usamos navigator local para evitar usar context tras el await
                          final navigator = Navigator.of(context);

                          final refresh = await navigator.push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditCompanyScreen(company: company),
                            ),
                          );

                          // Si vuelve con “true”, refrescamos la información
                          if (refresh == true && mounted) {
                            setState(() {
                              _hasUpdated = true; // Marca cambios realizados
                            });
                            await _refreshCompany();
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Company'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    // Botón ver admins
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CompanyAdminsScreen(
                                companyId: widget.companyId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people_alt_outlined),
                        label: const Text('See Administrators'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
