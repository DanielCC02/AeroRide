import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/search_criteria.dart';

class PlaneListScreen extends StatefulWidget {
  final SearchCriteria criteria;
  const PlaneListScreen({super.key, required this.criteria});

  @override
  State<PlaneListScreen> createState() => _PlaneListScreenState();
}

class _PlaneListScreenState extends State<PlaneListScreen> {
  RangeValues price = const RangeValues(300, 1500);

  @override
  void initState() {
    super.initState();
    // Log de diagnóstico: verifica que sí llegan los criterios
    final c = widget.criteria;
    // ignore: avoid_print
    print('[PlaneListScreen] from=${c.from.codeIata} to=${c.to.codeIata} '
        'pax=${c.passengers} dep=${c.departure}');
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.criteria;

    // Filtra por capacidad + rango precio. Si la lista queda vacía, igual dibuja UI.
    final filtered = planes.where((p) {
      final okCap = p.seats >= c.passengers;
      final okPrice = p.priceUsd >= price.start && p.priceUsd <= price.end;
      return okCap && okPrice;
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Select Aircraft'),
          titleTextStyle: const TextStyle(
            color: Color(0xFFFF0000),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFF0000)),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 1,
        ),
        body: Column(
          children: [
            // ---------- Filtro de precio ----------
            ExpansionTile(
              title: const Text('Price filter'),
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Precio (USD)'),
                      RangeSlider(
                        values: price,
                        min: 300,
                        max: 2000,
                        divisions: 17,
                        labels: RangeLabels(
                          price.start.round().toString(),
                          price.end.round().toString(),
                        ),
                        onChanged: (v) => setState(() => price = v),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'From: ${c.from.codeIata} • To: ${c.to.codeIata} • Pax: ${c.passengers} • ${_fmtDateTime(c.departure)}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 0),

            // ---------- Resultados ----------
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No aircraft match the current filters'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final p = filtered[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          elevation: 1.5,
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Selected ${p.model} | ${c.from.codeIata}→${c.to.codeIata} '
                                    '| ${_fmtDateTime(c.departure)} | ${c.passengers} pax',
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagen con fallback para evitar crasheos silenciosos
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.asset(
                                    p.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) {
                                      return Container(
                                        color: Colors.black12,
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.broken_image, size: 48),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.model.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _InfoChip(
                                            icon: Icons.event_seat,
                                            label: '${p.seats} SEATS',
                                          ),
                                          const SizedBox(width: 10),
                                          _InfoChip(
                                            icon: Icons.monitor_weight,
                                            label: 'MAX WEIGHT ${_kgToLb(p.maxWeightKg)} LB',
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              const Icon(Icons.attach_money, size: 18),
                                              Text(
                                                p.priceUsd.toStringAsFixed(0),
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDateTime(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$mi';
  }

  static String _kgToLb(double kg) => (kg * 2.20462).round().toString();
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
        color: Colors.black12, // uso color fijo para evitar temas raros
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
