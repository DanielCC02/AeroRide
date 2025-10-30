import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../models/passenger_info.dart';
import 'passengers_form_screen.dart';
import 'homepage_screen.dart'; // deja este import como lo tengas en tu proyecto

/// ReservationScreen
/// ---------------------------------------------------------------------------
/// Pantalla de detalle de reservación (mock faithful al diseño).
class ReservationScreen extends StatefulWidget {
  final Reservation reservation;
  const ReservationScreen({super.key, required this.reservation});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  bool lapInfant = false;
  bool dog = false;
  List<PassengerInfo> _passengers = [];

  @override
  void initState() {
    super.initState();
    lapInfant = widget.reservation.lapInfant;
    dog = widget.reservation.dog;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final theme = Theme.of(context);
    final eft = Duration(minutes: r.estFlightTimeMin.round());
    final arr = r.date.add(eft);
    const red = Color(0xFFFF0000);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservation',
          style: TextStyle(color: red, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Imagen
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    r.plane.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                ],
              ),
            ),

            // Cabecera
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      r.plane.model.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.event_seat,
                        size: 18,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${r.plane.seats} seats',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.attach_money,
                        size: 18,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        r.priceUsd.toStringAsFixed(0),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 0),

            // Itinerary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Itinerary',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Row(
                          children: const [
                            Text(
                              'Show on the map',
                              style: TextStyle(color: Colors.red),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.red,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _InfoKVP(
                          title: _formatMonthDay(r.date),
                          value: _formatTime(r.date),
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.airplanemode_active,
                            color: Colors.black54,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EFT ${_fmtDur(eft)}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: _InfoKVP(
                          title: _formatMonthDay(arr),
                          value: _formatTime(arr),
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.from.codeIATA,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${r.from.name}\n${r.from.country}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.flight, color: Colors.black54, size: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              r.to.codeIATA,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${r.to.name}\n${r.to.country}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Passengers
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Passengers',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context)
                            .push<List<PassengerInfo>>(
                              MaterialPageRoute(
                                builder: (_) => PassengersFormScreen(
                                  passengersCount: r.passengers,
                                  initialPassengers:
                                      _passengers, // persistencia al reabrir
                                ),
                              ),
                            );

                        if (result != null && result.isNotEmpty) {
                          setState(() => _passengers = result);

                          // Resumen rápido por SnackBar
                          final lines = result
                              .asMap()
                              .entries
                              .map((e) => 'P${e.key + 1}: ${e.value}')
                              .join('\n');

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lines),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Add Passengers Information',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  if (_passengers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_passengers.length} passengers added',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Companions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: lapInfant,
                    onChanged: (v) => setState(() => lapInfant = v),
                    title: const Text('Lap child (younger than 2)'),
                  ),
                  const Divider(height: 0),
                  SwitchListTile(
                    value: dog,
                    onChanged: (v) => setState(() => dog = v),
                    title: const Text('Dog'),
                  ),
                ],
              ),
            ),

            // Book
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_passengers.length != r.passengers) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please add all passengers information.',
                          ),
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Flight booked!')),
                    );

                    // Volver a Home con formulario limpio
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomePageScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Book',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- helpers de formato ----
  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'p.m.' : 'a.m.';
    return '$h:$mm $ampm';
  }

  String _formatMonthDay(DateTime dt) {
    const months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    return '${months[dt.month - 1]} ${dt.day} ${dt.year}';
  }

  String _fmtDur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
}

class _InfoKVP extends StatelessWidget {
  final String title;
  final String value;
  final bool alignEnd;
  const _InfoKVP({
    required this.title,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
