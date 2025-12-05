// lib/screens/empty_legs_list_screen.dart

import 'package:flutter/material.dart';
import '../models/empty_leg_summary_model.dart';
import 'empty_leg_reservation_screen.dart';

class EmptyLegsListScreen extends StatelessWidget {
  final List<EmptyLegSummaryModel> emptyLegs;

  const EmptyLegsListScreen({super.key, required this.emptyLegs});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF0000);

    // Ya vienen filtradas al futuro desde el TodayDealsSection
    final sorted = [...emptyLegs]
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Empty Legs',
          style: TextStyle(color: red, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: sorted.length,
        itemBuilder: (ctx, i) {
          final leg = sorted[i];
          return _EmptyLegListItem(
            leg: leg,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmptyLegReservationScreen(emptyLegId: leg.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyLegListItem extends StatelessWidget {
  final EmptyLegSummaryModel leg;
  final VoidCallback onTap;

  const _EmptyLegListItem({required this.leg, required this.onTap});

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final m = months[local.month - 1].substring(0, 3).toUpperCase();
    final weekday = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][local.weekday - 1];
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final mm = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '$weekday ${local.day} $m $hour12:$mm $ampm';
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF0000);
    final dateStr = _formatDateTime(leg.departureTime);

    // ⬇️ El backend manda algo tipo 2.08 para representar 208
    final int displayPrice = (leg.price * 100).round();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Fila: fecha + EMPTY LEG =====
              Row(
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '➔ EMPTY LEG',
                    style: TextStyle(
                      color: red,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ===== Fila: aeropuertos =====
              Row(
                children: [
                  Expanded(
                    child: Text(
                      leg.fromName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.flight_takeoff,
                    size: 18,
                    color: Colors.black54,
                  ),
                  Expanded(
                    child: Text(
                      leg.toName,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ===== Parte baja =====
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila 1: modelo + seats
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          leg.aircraftModel.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_alt,
                            size: 16,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${leg.seats} SEATS',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Fila 2: MAX WEIGHT  ... |  $ PRECIO (ya corregido)
                  Row(
                    children: [
                      Expanded(
                        child: leg.maxWeightLb != null
                            ? Text(
                                'MAX WEIGHT ${leg.maxWeightLb!.toStringAsFixed(0)} LB',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$ $displayPrice',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: red,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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
