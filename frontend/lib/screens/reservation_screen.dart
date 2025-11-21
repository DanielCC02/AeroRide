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

// Usa ESTE form (retorna List<PassengerInfo>)
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

  // Opciones
  bool lapInfant = false;
  bool dog = false;

  // Pasajeros (del form)
  List<PassengerInfo> _passengers = [];

  // Flujo
  bool _booking = false;
  bool _estimating = false;

  // Estimate
  String? _estimateError;
  double? _estimatedTotal;
  int? _estimateMinutes;
  models.ReservationEstimateResponse? _estimateRaw;

  // Resoluciones
  int? _effectiveCompanyId;
  String? _modelForApi; // exactamente el modelo que mandaremos
  AircraftModel? _assignedPreview;

  // Aviso cuando el avión real pertenece a otra compañía
  String? _companyMismatchWarning;

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

            if (_companyMismatchWarning != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Material(
                  color: Colors.amberAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.black87,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _companyMismatchWarning!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ===== Itinerary =====
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

            const Divider(height: 0),

            // ===== Passengers & Options =====
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  const Text(
                    'Passengers & Options',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _openPassengersForm,
                    icon: const Icon(Icons.group_add),
                    label: Text(
                      _passengers.isEmpty
                          ? 'Fill passengers info'
                          : 'Edit passengers info',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            if (_passengers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_passengers.length, (i) {
                    final p = _passengers[i];
                    final name =
                        '${p.name ?? 'Passenger'} ${p.lastName ?? (i + 1)}'
                            .trim();
                    return Chip(
                      avatar: Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.red.shade700,
                      ),
                      label: Text(
                        name,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.red.shade50,
                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                    );
                  }),
                ),
              ),
            SwitchListTile(
              title: const Text('Lap infant'),
              subtitle: const Text(
                'Infant travels on lap (counts for weight / some fees)',
              ),
              value: lapInfant,
              onChanged: (v) => setState(() {
                lapInfant = v;
                _refreshEstimate();
              }),
            ),
            SwitchListTile(
              title: const Text('Assistance animal (dog)'),
              value: dog,
              onChanged: (v) => setState(() => dog = v),
            ),

            // ===== Price breakdown trigger =====
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onPressed: (_estimatedTotal != null) ? _showBreakdown : null,
                  icon: const Icon(Icons.receipt_long),
                  label: const Text(
                    'View price breakdown',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),

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

  // ================== Bottom bar ==================
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
                onPressed: _booking ? null : _confirmAndBook,
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

  // ---- Timezone helpers (pulidos) ----
  DateTime _localAirportToUtc(DateTime localWallTime, String? timeZoneId) {
    final offset = _tzOffsetHours(timeZoneId, localWallTime);
    final naiveAsUtc = DateTime.utc(
      localWallTime.year,
      localWallTime.month,
      localWallTime.day,
      localWallTime.hour,
      localWallTime.minute,
    );
    return naiveAsUtc.subtract(Duration(hours: offset));
  }

  int _tzOffsetHours(String? tz, DateTime at) {
    final id = (tz ?? '').trim();
    if (id.isEmpty || id == 'America/Costa_Rica') return -6; // sin DST
    if (id == 'America/Guatemala') return -6;
    if (id == 'America/Mexico_City') {
      final m = at.month;
      final isDST = (m >= 4 && m <= 10);
      return isDST ? -5 : -6;
    }
    if (id == 'America/Los_Angeles' || id == 'US/Pacific' || id == 'PST8PDT') {
      final m = at.month;
      final isDST = (m >= 3 && m <= 11);
      return isDST ? -7 : -8;
    }
    final match = RegExp(
      r'([+-])(\d{1,2})(?::?(\d{2}))?',
    ).firstMatch(id.replaceAll(' ', ''));
    if (match != null) {
      final sign = match.group(1) == '-' ? -1 : 1;
      final h = int.tryParse(match.group(2) ?? '0') ?? 0;
      final mm = int.tryParse(match.group(3) ?? '0') ?? 0;
      final total = sign * (h + (mm >= 30 ? 1 : 0));
      return total;
    }
    return -6; // fallback Centroamérica
  }

  Future<void> _refreshEstimate() async {
    setState(() {
      _estimating = true;
      _estimateError = null;
      _companyMismatchWarning = null; // limpiamos aviso previo
    });

    try {
      final c = widget.criteria;
      final resolvedCompanyId = await _resolveCompanyId();
      _effectiveCompanyId = resolvedCompanyId;

      final modelForEstimate = (_modelForApi ?? widget.aircraftModel).trim();

      // Usa hora local del aeropuerto (no del dispositivo)
      final depUtc = _localAirportToUtc(c.departure, c.from.timeZone);
      final retUtc = (c.isRoundTrip && c.returnDateTime != null)
          ? _localAirportToUtc(c.returnDateTime!, c.to.timeZone)
          : null;

      final segs = <SegmentDto>[
        SegmentDto(
          departureAirportId: c.from.id,
          arrivalAirportId: c.to.id,
          departureTime: depUtc,
          arrivalTime: depUtc, // el back recalcula con ETE
        ),
      ];
      if (retUtc != null) {
        segs.add(
          SegmentDto(
            departureAirportId: c.to.id,
            arrivalAirportId: c.from.id,
            departureTime: retUtc,
            arrivalTime: retUtc,
          ),
        );
      }

      final passengersTotal = c.passengers + (lapInfant ? 1 : 0);

      final req = ReservationEstimateRequest(
        companyId: resolvedCompanyId,
        aircraftModel: modelForEstimate,
        totalPassengers: passengersTotal,
        segments: segs,
      );

      final models.ReservationEstimateResponse est = await _resSvc.estimate(
        req,
      );

      if (!mounted) return;

      setState(() {
        _estimateRaw = est;
        _estimatedTotal = est.totalPrice;
        _estimateMinutes = est.totalMinutes.round();
      });

      // ===== Preview opcional + aviso si la compañía no coincide =====
      try {
        final preview = await _airSvc.findFirstAircraftByCompanyAndModel(
          companyId: resolvedCompanyId,
          model: modelForEstimate,
        );

        if (!mounted) return;

        String? warning;

        if (preview != null) {
          final selectedName = widget.companyName.trim().toLowerCase();
          final previewName = preview.companyName.trim().toLowerCase();

          if (selectedName.isNotEmpty &&
              previewName.isNotEmpty &&
              selectedName != previewName) {
            warning =
                'Heads up: the available aircraft for this model belongs to a '
                'different company (${preview.companyName}) than the one you '
                'filtered (${widget.companyName}).';
          }
        }

        setState(() {
          _assignedPreview = preview;
          _companyMismatchWarning = warning;
        });
      } catch (_) {
        // Si falla el preview, simplemente no mostramos matrícula ni warning
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _estimateError = 'No fue posible estimar el precio: $e');
    } finally {
      if (mounted) setState(() => _estimating = false);
    }
  }

  // ========= Confirm + Book =========
  Future<void> _confirmAndBook() async {
    if (_booking) return;

    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm reservation'),
        content: const Text('¿Deseas continuar y crear la reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (shouldContinue != true) return;

    await _book();
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

      // Misma regla de zona horaria del aeropuerto
      final depUtc = _localAirportToUtc(
        _roundTo5(c.departure),
        c.from.timeZone,
      );
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
        final backDepUtc = _localAirportToUtc(
          _roundTo5(c.returnDateTime!),
          c.to.timeZone,
        );
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
        aircraftModel: modelForCreate,
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

  // ================== UI actions ==================
  Future<void> _openPassengersForm() async {
    final c = widget.criteria;
    final result = await Navigator.of(context).push<List<PassengerInfo>>(
      MaterialPageRoute(
        builder: (_) => PassengersFormScreen(
          passengersCount: c.passengers,
          initialPassengers: _passengers,
        ),
      ),
    );
    if (result != null) {
      setState(() => _passengers = result);
    }
  }

  // ---- Price breakdown sheet (FUNCIONA) ----
  void _showBreakdown() {
    if (_estimatedTotal == null) return;

    final total = _estimatedTotal!;
    final minutes = _estimateMinutes ?? 0;
    final minuteCost = _assignedPreview?.minuteCost;

    // Intenta leer breakdown del API si existe
    Map<String, dynamic>? apiBk;
    try {
      final m = (_estimateRaw as dynamic).toJson() as Map<String, dynamic>;
      final b = m['breakdown'];
      if (b is Map<String, dynamic>) {
        apiBk = Map<String, dynamic>.from(b);
      }
    } catch (_) {
      try {
        final b = (_estimateRaw as dynamic).breakdown;
        if (b is Map<String, dynamic>) apiBk = b;
      } catch (_) {}
    }

    double? baseFlight;
    double? otherFees;
    if (minuteCost != null && minutes > 0) {
      baseFlight = minuteCost * minutes;
      otherFees = total - baseFlight;
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Price breakdown',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Passengers'),
                  Text(
                    '${widget.criteria.passengers}'
                    '${lapInfant ? ' + lap infant' : ''}',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated flight time'),
                  Text('$minutes min'),
                ],
              ),

              if (baseFlight != null) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Base flight (${minuteCost!.toStringAsFixed(2)}/min)'),
                    Text(baseFlight.toStringAsFixed(2)),
                  ],
                ),
              ],

              if (apiBk != null) ...[
                const Divider(),
                ...apiBk.entries.map(
                  (e) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_labelize(e.key)),
                      Text(_fmtMoney(e.value)),
                    ],
                  ),
                ),
              ] else if (otherFees != null) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Other fees (taxes, handling, etc.)'),
                    Text(otherFees.toStringAsFixed(2)),
                  ],
                ),
              ],

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    total.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _labelize(String k) {
    return k
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'(^| )\w'), (m) => m.group(0)!.toUpperCase());
  }

  String _fmtMoney(Object? v) {
    if (v is num) return v.toStringAsFixed(2);
    try {
      return double.parse(v.toString()).toStringAsFixed(2);
    } catch (_) {
      return v.toString();
    }
  }

  // ================== HELPERS ==================
  PassengerCreateRequest _mapPassenger(PassengerInfo p) {
    // Aquí usamos directamente los campos del modelo ya alineados con la BD
    final firstName = (p.name ?? '').trim();
    final middleName = (p.middleName ?? '').trim();
    final lastName = (p.lastName ?? '').trim();
    final passport = (p.passport ?? '').trim().toUpperCase();
    final nationality = (p.nationality ?? '').trim();
    final dob = p.dateOfBirth ?? DateTime(2000, 1, 1);

    final genderString = p.gender.apiValue; // 'Masculino' / 'Femenino'

    return PassengerCreateRequest(
      name: firstName,
      middleName: middleName,
      lastName: lastName,
      passport: passport,
      nationality: nationality,
      dateOfBirth: dob,
      gender: genderString,
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
    final dLon = deg2rad(lat2 - lat1);
    final dLon2 = deg2rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg2rad(lat1)) *
            math.cos(deg2rad(lat2)) *
            math.sin(dLon2 / 2) *
            math.sin(dLon2 / 2);
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
