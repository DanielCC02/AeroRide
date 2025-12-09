// lib/screens/plane_list_screen.dart
import 'package:flutter/material.dart';

import '../models/search_criteria.dart';
import '../models/available_aircraft_model.dart';
import '../services/aircraft_service.dart';
import 'reservation_screen.dart';

enum PlaneSortOption { companyThenModel, modelAZ, seatsAsc, seatsDesc }

class PlaneListScreen extends StatefulWidget {
  final SearchCriteria criteria;
  const PlaneListScreen({super.key, required this.criteria});

  @override
  State<PlaneListScreen> createState() => _PlaneListScreenState();
}

class _PlaneListScreenState extends State<PlaneListScreen> {
  final _svc = AircraftService();
  late Future<List<AvailableAircraftModel>> _future;

  String? _selectedCompany; // null = all
  String? _selectedModel; // null = all
  PlaneSortOption _sortOption = PlaneSortOption.companyThenModel;

  @override
  void initState() {
    super.initState();
    _future = _svc.listAvailableModelsFor(widget.criteria);
  }

  Future<void> _reload() async {
    final fut = _svc.listAvailableModelsFor(widget.criteria);
    setState(() {
      _future = fut;
    });
    await fut;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Aircraft'),
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

            final allItems = (snap.data ?? <AvailableAircraftModel>[]).toList();

            if (allItems.isEmpty) {
              return _EmptyState(
                onModify: () => Navigator.of(context).pop(),
                onRetry: _reload,
              );
            }

            // Build dynamic lists of companies and models
            final companySet = <String>{};
            final modelSet = <String>{};

            for (final m in allItems) {
              if (m.companyName.trim().isNotEmpty) {
                companySet.add(m.companyName.trim());
              }
              if (m.model.trim().isNotEmpty) {
                modelSet.add(m.model.trim());
              }
            }

            final companies = companySet.toList()..sort();
            final models = modelSet.toList()..sort();

            // Apply filters
            var filtered = allItems;

            if (_selectedCompany != null && _selectedCompany!.isNotEmpty) {
              filtered = filtered
                  .where(
                    (m) =>
                        m.companyName.trim().toLowerCase() ==
                        _selectedCompany!.trim().toLowerCase(),
                  )
                  .toList();
            }

            if (_selectedModel != null && _selectedModel!.isNotEmpty) {
              filtered = filtered
                  .where(
                    (m) =>
                        m.model.trim().toLowerCase() ==
                        _selectedModel!.trim().toLowerCase(),
                  )
                  .toList();
            }

            if (filtered.isEmpty) {
              return Column(
                children: [
                  _FilterBar(
                    totalFound: 0,
                    companies: companies,
                    models: models,
                    selectedCompany: _selectedCompany,
                    selectedModel: _selectedModel,
                    sortOption: _sortOption,
                    onCompanyChanged: (value) {
                      setState(() => _selectedCompany = value);
                    },
                    onModelChanged: (value) {
                      setState(() => _selectedModel = value);
                    },
                    onSortChanged: (value) {
                      setState(() => _sortOption = value);
                    },
                  ),
                  Expanded(
                    child: _EmptyState(
                      onModify: () => Navigator.of(context).pop(),
                      onRetry: _reload,
                    ),
                  ),
                ],
              );
            }

            // Sort base list
            filtered.sort((a, b) {
              switch (_sortOption) {
                case PlaneSortOption.modelAZ:
                  final cmpModel = a.model.compareTo(b.model);
                  if (cmpModel != 0) return cmpModel;
                  return a.companyName.compareTo(b.companyName);
                case PlaneSortOption.seatsAsc:
                  final cmpSeats = a.seats.compareTo(b.seats);
                  if (cmpSeats != 0) return cmpSeats;
                  return a.model.compareTo(b.model);
                case PlaneSortOption.seatsDesc:
                  final cmpSeats = b.seats.compareTo(a.seats);
                  if (cmpSeats != 0) return cmpSeats;
                  return a.model.compareTo(b.model);
                case PlaneSortOption.companyThenModel:
                  final c1 = a.companyName.compareTo(b.companyName);
                  if (c1 != 0) return c1;
                  return a.model.compareTo(b.model);
              }
            });

            // Group by companyId and deduplicate (companyId + model)
            final grouped = <int, _CompanyGroup>{};
            for (final m in filtered) {
              final companyId = m.companyId;
              final companyName = (m.companyName.isNotEmpty
                  ? m.companyName
                  : (companyId > 0 ? 'Company #$companyId' : 'Company'));

              grouped.putIfAbsent(
                companyId,
                () => _CompanyGroup(companyId, companyName),
              );

              final key = '$companyId|${m.model.trim()}';
              if (!grouped[companyId]!.seenKeys.contains(key)) {
                grouped[companyId]!.seenKeys.add(key);
                grouped[companyId]!.models.add(m);
              }
            }

            final groups = grouped.values.toList()
              ..sort((a, b) => a.companyName.compareTo(b.companyName));

            for (final g in groups) {
              g.models.sort((a, b) {
                switch (_sortOption) {
                  case PlaneSortOption.modelAZ:
                    return a.model.compareTo(b.model);
                  case PlaneSortOption.seatsAsc:
                    final cmpSeats = a.seats.compareTo(b.seats);
                    if (cmpSeats != 0) return cmpSeats;
                    return a.model.compareTo(b.model);
                  case PlaneSortOption.seatsDesc:
                    final cmpSeats = b.seats.compareTo(a.seats);
                    if (cmpSeats != 0) return cmpSeats;
                    return a.model.compareTo(b.model);
                  case PlaneSortOption.companyThenModel:
                    return a.model.compareTo(b.model);
                }
              });
            }

            final foundCount = groups.fold<int>(
              0,
              (acc, g) => acc + g.models.length,
            );

            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: groups.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, gi) {
                  if (gi == 0) {
                    return _FilterBar(
                      totalFound: foundCount,
                      companies: companies,
                      models: models,
                      selectedCompany: _selectedCompany,
                      selectedModel: _selectedModel,
                      sortOption: _sortOption,
                      onCompanyChanged: (value) {
                        setState(() => _selectedCompany = value);
                      },
                      onModelChanged: (value) {
                        setState(() => _selectedModel = value);
                      },
                      onSortChanged: (value) {
                        setState(() => _sortOption = value);
                      },
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
                              int cid = m.companyId;
                              final cname = m.companyName;
                              final criteria = widget.criteria;
                              final navigator = Navigator.of(context);

                              if (cid == 0 && cname.trim().isNotEmpty) {
                                try {
                                  final resolved = await _svc
                                      .getCompanyIdByName(cname);
                                  if (resolved != null) cid = resolved;
                                } catch (_) {}
                              }

                              final List<int> ids = m.aircraftIds
                                  .where((id) => id > 0)
                                  .toList();

                              int? primaryId = ids.isNotEmpty
                                  ? ids.first
                                  : null;
                              if (primaryId == null && m.id != null) {
                                if (m.id! > 0) primaryId = m.id!;
                              }

                              navigator.push(
                                MaterialPageRoute(
                                  builder: (_) => ReservationScreen(
                                    criteria: criteria,
                                    companyId: cid,
                                    companyName: cname,
                                    aircraftModel: m.model,
                                    headerImage: m.image,
                                    seats: m.seats,

                                    /// For preview only (NOT sent to backend)
                                    aircraftId: primaryId,

                                    /// REQUIRED BY BACKEND
                                    aircraftIds: ids.isNotEmpty
                                        ? ids
                                        : (primaryId != null
                                              ? <int>[primaryId]
                                              : []),
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

class _FilterBar extends StatelessWidget {
  final int totalFound;
  final List<String> companies;
  final List<String> models;
  final String? selectedCompany;
  final String? selectedModel;
  final PlaneSortOption sortOption;
  final ValueChanged<String?> onCompanyChanged;
  final ValueChanged<String?> onModelChanged;
  final ValueChanged<PlaneSortOption> onSortChanged;

  const _FilterBar({
    required this.totalFound,
    required this.companies,
    required this.models,
    required this.selectedCompany,
    required this.selectedModel,
    required this.sortOption,
    required this.onCompanyChanged,
    required this.onModelChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF0000);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Found $totalFound model(s)',
            style: const TextStyle(color: red, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Filter by company
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: selectedCompany,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All companies'),
                    ),
                    ...companies.map(
                      (c) =>
                          DropdownMenuItem<String?>(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: onCompanyChanged,
                ),
              ),
              const SizedBox(width: 8),

              // Filter by model
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: selectedModel,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All models'),
                    ),
                    ...models.map(
                      (m) =>
                          DropdownMenuItem<String?>(value: m, child: Text(m)),
                    ),
                  ],
                  onChanged: onModelChanged,
                ),
              ),
              const SizedBox(width: 8),

              // Sort by
              Expanded(
                child: DropdownButtonFormField<PlaneSortOption>(
                  initialValue: sortOption,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PlaneSortOption.companyThenModel,
                      child: Text('Company / Model'),
                    ),
                    DropdownMenuItem(
                      value: PlaneSortOption.modelAZ,
                      child: Text('Model A–Z'),
                    ),
                    DropdownMenuItem(
                      value: PlaneSortOption.seatsAsc,
                      child: Text('Seats ↑'),
                    ),
                    DropdownMenuItem(
                      value: PlaneSortOption.seatsDesc,
                      child: Text('Seats ↓'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) onSortChanged(v);
                  },
                ),
              ),
            ],
          ),
        ],
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
                      errorBuilder: (context, error, stackTrace) => Container(
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
                  Text(
                    m.model.isNotEmpty ? m.model : 'AIRCRAFT',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chips inside an Expanded + Wrap to avoid overflow
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            _InfoChip(
                              icon: Icons.apartment,
                              label: companyLabel,
                            ),
                            _InfoChip(
                              icon: Icons.event_seat,
                              label: '${m.seats} SEATS',
                            ),
                            if (m.baseCountry.isNotEmpty)
                              _InfoChip(
                                icon: Icons.public,
                                label: m.baseCountry,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (m.estimatedPrice != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
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
