// lib/screens/reservation_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/search_criteria.dart';
import '../models/passenger_info.dart';
import '../models/segment_dto.dart';

import '../models/reservation_estimate_request.dart';
import '../models/reservation_create_request.dart';
import '../models/reservation_estimate_response.dart' as models;

import '../services/reservation_service.dart' as rsvc;
import '../services/aircraft_service.dart' as asvc;
import '../models/aircraft_model.dart';

import 'passengers_form_screen.dart';
import 'reservation_route_map_screen.dart';
import 'homepage_screen.dart';

class ReservationScreen extends StatefulWidget {
  final SearchCriteria criteria;

  final int companyId; // id final que viene del item (o 0 si no se pudo)
  final String companyName; // solo para mostrar
  final String aircraftModel; // EXACTO como BD

  final String? headerImage;
  final int? seats;

  const ReservationScreen({
    super.key,
    required this.criteria,
    required this.companyId,
    required this.companyName,
    required this.aircraftModel,
    this.headerImage,
    this.seats,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _airSvc = asvc.AircraftService();
  final _resSvc = rsvc.ReservationService();

  bool lapInfant = false;
  bool dog = false;
  List<PassengerInfo> _passengers = [];
  bool _booking = false;

  bool _estimating = false;
  String? _estimateError;
  double? _estimatedTotal;
  int? _estimateMinutes;

  int? _effectiveCompanyId;
  String? _modelForApi; // exactamente el modelo que mandaremos
  AircraftModel? _assignedPreview;

  @override
  void initState() {
    super.initState();
    _modelForApi = widget.aircraftModel; // exacto
    _refreshEstimate();
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF0000);
    final c = widget.criteria;

    final legs = (c.isRoundTrip && c.returnDateTime != null) ? 2 : 1;
    final perLegMinutes = (_estimateMinutes != null && legs > 0)
        ? (_estimateMinutes! / legs).ceil()
        : _estimateEteMinutes(
            c.from.latitude,
            c.from.longitude,
            c.to.latitude,
            c.to.longitude,
          );

    final eft = Duration(minutes: perLegMinutes);
    final arr = c.departure.add(eft);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservation',
          style: TextStyle(color: red, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ReservationRouteMapScreen(from: c.from, to: c.to),
                ),
              );
            },
            icon: const Icon(Icons.map, color: red),
            label: const Text('Show on the map', style: TextStyle(color: red)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(eft),
            // … resto igual que antes …
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        'Itinerary',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _InfoKVP(
                          title: _formatMonthDay(widget.criteria.departure),
                          value: _formatTime(widget.criteria.departure),
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
                              widget.criteria.from.codeIATA,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.criteria.from.name}\n${widget.criteria.from.country}',
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
                              widget.criteria.to.codeIATA,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.criteria.to.name}\n${widget.criteria.to.country}',
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

            // … pasajeros / switches …
            if (_estimateError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Material(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _estimateError!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(red),
    );
  }

  Widget _buildBottomBar(Color red) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total (estimate)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _estimatedTotal != null
                            ? _estimatedTotal!.toStringAsFixed(0)
                            : (_estimating ? 'Calculating…' : '—'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _booking ? null : _book,
                child: _booking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Book',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== HEADER ==================
  Widget _buildHeader(Duration eft) {
    final img = (_assignedPreview?.image.isNotEmpty == true)
        ? _assignedPreview!.image
        : (widget.headerImage ?? '');

    // Título: usamos el modelo EXACTO si no hay matrícula
    final title = (_assignedPreview?.patent.isNotEmpty == true)
        ? _assignedPreview!.patent.toUpperCase()
        : (_modelForApi ?? widget.aircraftModel);

    final seats = _assignedPreview?.seats ?? widget.seats ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: (img.isNotEmpty)
              ? Image.network(
                  img,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.event_seat, size: 18, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    '$seats seats',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 0),
      ],
    );
  }

  // ================== NETWORK ==================
  Future<int> _resolveCompanyId() async {
    if (widget.companyId != 0) return widget.companyId;
    final id = await _airSvc.getCompanyIdByName(widget.companyName);
    if (id != null && id != 0) return id;
    // fallback no bloqueante: 0 → que el back decida
    return 0;
  }

  Future<void> _refreshEstimate() async {
    setState(() {
      _estimating = true;
      _estimateError = null;
    });

    try {
      final c = widget.criteria;
      final resolvedCompanyId = await _resolveCompanyId();
      _effectiveCompanyId = resolvedCompanyId;

      // Modelo EXACTO sin transformar
      final modelForEstimate = (_modelForApi ?? widget.aircraftModel).trim();

      final segs = <SegmentDto>[
        SegmentDto(
          departureAirportId: c.from.id,
          arrivalAirportId: c.to.id,
          departureTime: c.departure.toUtc(),
          arrivalTime: c.departure.toUtc(),
        ),
      ];
      if (c.isRoundTrip && c.returnDateTime != null) {
        segs.add(
          SegmentDto(
            departureAirportId: c.to.id,
            arrivalAirportId: c.from.id,
            departureTime: c.returnDateTime!.toUtc(),
            arrivalTime: c.returnDateTime!.toUtc(),
          ),
        );
      }

      final passengersTotal = c.passengers + (lapInfant ? 1 : 0);

      final req = ReservationEstimateRequest(
        companyId: resolvedCompanyId,
        aircraftModel: modelForEstimate, // EXACTO
        totalPassengers: passengersTotal,
        segments: segs,
      );

      final models.ReservationEstimateResponse est = await _resSvc.estimate(
        req,
      );

      if (!mounted) return;

      setState(() {
        _estimatedTotal = est.totalPrice;
        _estimateMinutes = est.totalMinutes.round();
      });

      // Preview opcional
      try {
        final preview = await _airSvc.findFirstAircraftByCompanyAndModel(
          companyId: resolvedCompanyId,
          model: modelForEstimate,
        );
        if (mounted) setState(() => _assignedPreview = preview);
      } catch (_) {}
    } catch (e) {
      setState(() => _estimateError = 'No fue posible estimar el precio: $e');
    } finally {
      if (mounted) setState(() => _estimating = false);
    }
  }

  Future<void> _book() async {
    final c = widget.criteria;

    if (_passengers.length != c.passengers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add all passengers information.')),
      );
      return;
    }

    setState(() => _booking = true);
    try {
      final resolvedCompanyId = await _resolveCompanyId();
      final modelForCreate = (_modelForApi ?? widget.aircraftModel).trim();

      final legs = (c.isRoundTrip && c.returnDateTime != null) ? 2 : 1;
      final perLeg = (_estimateMinutes != null && legs > 0)
          ? (_estimateMinutes! / legs).ceil()
          : _estimateEteMinutes(
              c.from.latitude,
              c.from.longitude,
              c.to.latitude,
              c.to.longitude,
            );

      final depUtc = _roundTo5(c.departure).toUtc();
      final arrUtc = depUtc.add(Duration(minutes: perLeg));

      final segments = <SegmentDto>[
        SegmentDto(
          departureAirportId: c.from.id,
          arrivalAirportId: c.to.id,
          departureTime: depUtc,
          arrivalTime: arrUtc,
        ),
      ];

      if (c.isRoundTrip && c.returnDateTime != null) {
        final backDepUtc = _roundTo5(c.returnDateTime!).toUtc();
        final backArrUtc = backDepUtc.add(Duration(minutes: perLeg));
        segments.add(
          SegmentDto(
            departureAirportId: c.to.id,
            arrivalAirportId: c.from.id,
            departureTime: backDepUtc,
            arrivalTime: backArrUtc,
          ),
        );
      }

      final passengers = _passengers.map(_mapPassenger).toList();

      final req = ReservationCreateRequest(
        companyId: resolvedCompanyId,
        aircraftModel: modelForCreate, // EXACTO
        porcentPrice: 100,
        totalPrice: (_estimatedTotal ?? 0).round(),
        isRoundTrip: c.isRoundTrip,
        assistanceAnimal: dog,
        lapChild: lapInfant,
        notes: '',
        passengers: passengers,
        segments: segments,
      );

      await _resSvc.create(req);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation created successfully.')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePageScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  // ================== HELPERS ==================
  PassengerCreateRequest _mapPassenger(PassengerInfo p) {
    String _pickName(PassengerInfo px) {
      try {
        final s = (px as dynamic).fullName as String?;
        if (s != null && s.trim().isNotEmpty) return s.trim();
      } catch (_) {}
      try {
        final s = (px as dynamic).name as String?;
        if (s != null && s.trim().isNotEmpty) return s.trim();
      } catch (_) {}
      try {
        final m = (px as dynamic).toJson() as Map<String, dynamic>;
        final s = (m['fullName'] ?? m['name'])?.toString();
        if (s != null && s.trim().isNotEmpty) return s.trim();
      } catch (_) {}
      return '';
    }

    DateTime _pickDob(PassengerInfo px) {
      try {
        final d = (px as dynamic).birthDate as DateTime?;
        if (d != null) return d;
      } catch (_) {}
      try {
        final d = (px as dynamic).dateOfBirth as DateTime?;
        if (d != null) return d;
      } catch (_) {}
      try {
        final m = (px as dynamic).toJson() as Map<String, dynamic>;
        final v = m['birthDate'] ?? m['dateOfBirth'];
        if (v is DateTime) return v;
        if (v is String) {
          final dt = DateTime.tryParse(v);
          if (dt != null) return dt;
        }
      } catch (_) {}
      return DateTime(2000, 1, 1);
    }

    String? _pickPassport(PassengerInfo px) {
      try {
        return (px as dynamic).passport as String?;
      } catch (_) {}
      try {
        final m = (px as dynamic).toJson() as Map<String, dynamic>;
        final v = m['passport'];
        return v?.toString();
      } catch (_) {}
      return null;
    }

    String _pickNationality(PassengerInfo px) {
      try {
        final s = (px as dynamic).nationality as String?;
        if (s != null) return s;
      } catch (_) {}
      return '';
    }

    String _pickGender(PassengerInfo px) {
      try {
        final s = (px as dynamic).gender?.toString().toLowerCase().trim();
        if (s != null && s.startsWith('f')) return 'Femenino';
        if (s != null && s.startsWith('m')) return 'Masculino';
      } catch (_) {}
      return 'Masculino';
    }

    return PassengerCreateRequest(
      name: _pickName(p),
      middleName: '',
      lastName: '',
      passport: _pickPassport(p) ?? '',
      nationality: _pickNationality(p),
      dateOfBirth: _pickDob(p),
      gender: _pickGender(p),
    );
  }

  DateTime _roundTo5(DateTime dt) {
    final r = dt.minute % 5;
    final add = r >= 3 ? (5 - r) : -r;
    final d2 = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute + add);
    return DateTime(d2.year, d2.month, d2.day, d2.hour, d2.minute);
  }

  int _estimateEteMinutes(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    double deg2rad(double d) => d * math.pi / 180.0;
    final dLat = deg2rad(lat2 - lat1);
    final dLon = deg2rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg2rad(lat1)) *
            math.cos(deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distanceKm = R * c;
    final speedKmh = 300.0;
    final minutes = ((distanceKm / speedKmh) * 60).ceil() + 10;
    final rem = minutes % 5;
    return rem == 0 ? minutes : (minutes + (5 - rem));
  }

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

  static String _fmtDur(Duration d) {
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
