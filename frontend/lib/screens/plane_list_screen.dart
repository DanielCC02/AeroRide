// lib/screens/plane_list_screen.dart
import 'package:flutter/material.dart';

import '../models/search_criteria.dart';
import '../models/available_aircraft_model.dart';
import '../services/aircraft_service.dart';
import 'reservation_screen.dart';

/// Cambia a `null` si quieres ver TODOS los modelos (todas las compañías)
const String? _companyFilter = 'AeroCaribe';

class PlaneListScreen extends StatefulWidget {
  final SearchCriteria criteria;
  const PlaneListScreen({super.key, required this.criteria});

  @override
  State<PlaneListScreen> createState() => _PlaneListScreenState();
}

class _PlaneListScreenState extends State<PlaneListScreen> {
  final _svc = AircraftService();
  late Future<List<AvailableAircraftModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.listAvailableModelsFor(widget.criteria);
  }

  Future<void> _reload() async {
    setState(() => _future = _svc.listAvailableModelsFor(widget.criteria));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Aircraft (by Model)'),
          titleTextStyle: const TextStyle(
            color: Color(0xFFFF0000),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFF0000)),
          elevation: 1,
        ),
        body: FutureBuilder<List<AvailableAircraftModel>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }

            var items = (snap.data ?? <AvailableAircraftModel>[]).toList();

            // Filtro opcional por compañía para la prueba
            if (_companyFilter != null && _companyFilter!.trim().isNotEmpty) {
              final f = _companyFilter!.trim().toLowerCase();
              items = items
                  .where((m) => (m.companyName).trim().toLowerCase() == f)
                  .toList();
            }

            if (items.isEmpty) {
              return _EmptyState(
                onModify: () => Navigator.of(context).pop(),
                onRetry: _reload,
              );
            }

            // Orden por compañía y luego por modelo (ambos exactos para mostrar)
            items.sort((a, b) {
              final c1 = (a.companyName).compareTo(b.companyName);
              if (c1 != 0) return c1;
              return a.model.compareTo(b.model);
            });

            // Agrupar por compañía y deduplicar por (companyId|modelo EXACTO)
            final grouped = <int, _CompanyGroup>{};
            for (final m in items) {
              final companyId = m.companyId;
              final companyName = (m.companyName.isNotEmpty
                  ? m.companyName
                  : (companyId > 0 ? 'Company #$companyId' : 'Company'));
              grouped.putIfAbsent(
                companyId,
                () => _CompanyGroup(companyId, companyName),
              );

              final key = '$companyId|${m.model.trim()}'; // ← exacto
              if (!grouped[companyId]!.seenKeys.contains(key)) {
                grouped[companyId]!.seenKeys.add(key);
                grouped[companyId]!.models.add(m);
              }
            }

            final groups = grouped.values.toList()
              ..sort((a, b) => a.companyName.compareTo(b.companyName));
            final foundCount = groups.fold<int>(
              0,
              (acc, g) => acc + g.models.length,
            );

            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: groups.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, gi) {
                  if (gi == 0) {
                    final filterLabel = _companyFilter == null
                        ? 'All companies'
                        : 'Company: ${_companyFilter!}';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3F3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Found $foundCount model(s)',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            filterLabel,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final g = groups[gi - 1];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CompanyHeader(name: g.companyName),
                      const SizedBox(height: 8),
                      ...g.models.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ModelCard(
                            model: m,
                            onTap: () async {
                              // Resolver companyId por nombre si viene 0
                              int cid = m.companyId;
                              final cname = m.companyName;
                              if (cid == 0 && cname.trim().isNotEmpty) {
                                try {
                                  final resolved = await _svc
                                      .getCompanyIdByName(cname);
                                  if (resolved != null) cid = resolved;
                                } catch (_) {}
                              }

                              final c = widget.criteria;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReservationScreen(
                                    criteria: c,
                                    companyId: cid, // id final
                                    companyName: cname, // solo display
                                    aircraftModel: m.model, // EXACTO
                                    headerImage: m.image,
                                    seats: m.seats,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompanyGroup {
  final int companyId;
  final String companyName;
  final List<AvailableAircraftModel> models = [];
  final Set<String> seenKeys = <String>{};
  _CompanyGroup(this.companyId, this.companyName);
}

class _CompanyHeader extends StatelessWidget {
  final String name;
  const _CompanyHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.apartment, color: Colors.red, size: 18),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.red,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  final AvailableAircraftModel model;
  final VoidCallback onTap;
  const _ModelCard({required this.model, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final m = model;
    final companyLabel = m.companyName.isNotEmpty
        ? m.companyName
        : (m.companyId > 0 ? 'Company #${m.companyId}' : 'Company');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: (m.image.isNotEmpty)
                  ? Image.network(
                      m.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    )
                  : Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.flight, size: 48),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👇 Modelo EXACTO (sin transformar)
                  Text(
                    m.model.isNotEmpty ? m.model : 'AIRCRAFT',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoChip(icon: Icons.apartment, label: companyLabel),
                      const SizedBox(width: 10),
                      _InfoChip(
                        icon: Icons.event_seat,
                        label: '${m.seats} SEATS',
                      ),
                      const Spacer(),
                      if (m.estimatedPrice != null)
                        Row(
                          children: [
                            const Icon(Icons.attach_money, size: 18),
                            Text(
                              m.estimatedPrice!.toStringAsFixed(0),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onModify;
  final VoidCallback onRetry;
  const _EmptyState({required this.onModify, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        color: const Color(0xFFFFEFEF),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.red.shade100),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          width: 320,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.airplane_ticket, color: Colors.red, size: 28),
              const SizedBox(height: 10),
              const Text(
                'No aircraft available',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We couldn't find any available aircraft for your selection.\n\nTry adjusting date/time or passenger count.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.25),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: onModify,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    child: const Text('Modify search'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
