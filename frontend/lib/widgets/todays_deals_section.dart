// lib/widgets/todays_deals_section.dart

import 'package:flutter/material.dart';
import '../services/empty_leg_service.dart';
import '../models/empty_leg_summary_model.dart';
import '../screens/empty_legs_list_screen.dart';
import '../screens/empty_leg_reservation_screen.dart';

class TodaysDealsSection extends StatefulWidget {
  const TodaysDealsSection({super.key});

  @override
  State<TodaysDealsSection> createState() => _TodaysDealsSectionState();
}

class _TodaysDealsSectionState extends State<TodaysDealsSection> {
  final _svc = EmptyLegService();
  late Future<List<EmptyLegSummaryModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.getEmptyLegs();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF0000);
    final today = DateTime.now();

    return FutureBuilder<List<EmptyLegSummaryModel>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Could not load Today\'s Deals.',
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        }

        final all = (snap.data ?? [])
            .where(
              (e) => !e.departureTime.isBefore(
                DateTime(today.year, today.month, today.day),
              ),
            )
            .toList();

        final todays = all
            .where((e) => _isSameDay(e.departureTime.toLocal(), today))
            .toList();

        if (all.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Text(
                    'Today\'s Deals',
                    style: TextStyle(
                      color: red,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EmptyLegsListScreen(emptyLegs: all),
                        ),
                      );
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(color: red, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Cards de hoy
            if (todays.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'No empty legs available for today. Please check the upcoming days under "View all".',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: todays
                      .map(
                        (e) => _EmptyLegCard(
                          leg: e,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EmptyLegReservationScreen(emptyLegId: e.id),
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyLegCard extends StatelessWidget {
  final EmptyLegSummaryModel leg;
  final VoidCallback onTap;
  const _EmptyLegCard({required this.leg, required this.onTap});

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

    // ⬇️ Igual que en la lista: ajustamos el precio
    final int displayPrice = (leg.price * 100).round();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primera fila: fecha + "EMPTY LEG"
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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

              // Segunda fila: from -> to
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

              // Tercera fila: modelo + seats arriba, max weight + precio abajo
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
