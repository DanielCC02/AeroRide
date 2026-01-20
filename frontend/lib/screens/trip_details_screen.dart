import 'package:flutter/material.dart';

import '../models/reservation_response.dart';
import '../services/reservation_service.dart';
import '../widgets/user_trips/contact_operators.dart';

class TripDetailsScreen extends StatefulWidget {
  final int reservationId;

  const TripDetailsScreen({
    super.key,
    required this.reservationId,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final ReservationService _service = ReservationService();

  ReservationResponse? _reservation;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReservation();
  }

  Future<void> _loadReservation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _service.getById(widget.reservationId);
      if (!mounted) return;
      setState(() {
        _reservation = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ==========================================================
  // UPCOMING CHECK
  // ==========================================================
  bool get _isUpcomingTrip {
    if (_reservation == null) return false;

    final now = DateTime.now();
    return _reservation!.flights.any(
      (f) => f.status != 'Completed' && f.departureTime.toLocal().isAfter(now),
    );
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Trip details'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!)
              : _reservation == null
                  ? const Center(child: Text('Reservation not found'))
                  : _buildContent(),

      // 👇 BOTÓN SOLO SI ES UPCOMING
      bottomNavigationBar: _isUpcomingTrip
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.support_agent),
                    label: const Text(
                      'Contact operator',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _openContactOperatorSheet,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // ==========================================================
  // CONTENT
  // ==========================================================
  Widget _buildContent() {
    final r = _reservation!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SectionCard(
            title: 'Reservation',
            icon: Icons.confirmation_number,
            children: [
              _InfoRow('Code', r.reservationCode),
              _InfoRow('Status', r.status),
              _InfoRow('Company', r.companyName ?? '-'),
              _InfoRow('Total', '\$${r.totalPrice}'),
            ],
          ),
          _SectionCard(
            title: 'Flights',
            icon: Icons.flight,
            children: r.flights.isEmpty
                ? const [
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'No flights associated.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ]
                : r.flights.map(_buildFlightCard).toList(),
          ),
          _SectionCard(
            title: 'Passengers',
            icon: Icons.group,
            children: r.passengers.isEmpty
                ? const [
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'No passengers found.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ]
                : r.passengers
                    .map(
                      (p) => _InfoRow(
                        '${p.name} ${p.lastName}',
                        '${p.gender} · ${p.age} years',
                      ),
                    )
                    .toList(),
          ),
          _SectionCard(
            title: 'Options',
            icon: Icons.tune,
            children: [
              _InfoRow('Round trip', r.isRoundTrip ? 'Yes' : 'No'),
              _InfoRow('Lap child', r.lapChild ? 'Yes' : 'No'),
              _InfoRow(
                'Assistance animal',
                r.assistanceAnimal ? 'Yes' : 'No',
              ),
            ],
          ),
          if (r.notes.isNotEmpty)
            _SectionCard(
              title: 'Notes',
              icon: Icons.note,
              children: [
                Text(
                  r.notes,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // FLIGHT CARD
  // ==========================================================
  Widget _buildFlightCard(FlightRes f) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _InfoRow(
            'Route',
            '${f.departureAirportName ?? '-'} → ${f.arrivalAirportName ?? '-'}',
          ),
          _InfoRow('Departure', _formatDateTime(f.departureTime)),
          _InfoRow('Arrival', _formatDateTime(f.arrivalTime)),
          _InfoRow('Duration', '${f.durationMinutes} min'),
          _InfoRow('Aircraft', f.aircraftModel ?? '-'),
          _InfoRow('Operator', f.companyName ?? '-'),
          _InfoRow('Status', f.status),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} $h:$m';
  }

  // ==========================================================
  // CONTACT OPERATOR
  // ==========================================================
  void _openContactOperatorSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ContactOperatorsSheet(),
    );
  }
}

// ==========================================================
// UI COMPONENTS
// ==========================================================
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}