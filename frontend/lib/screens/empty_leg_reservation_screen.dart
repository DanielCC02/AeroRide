// lib/screens/empty_leg_reservation_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/empty_leg_detail_model.dart';
import '../services/empty_leg_service.dart';

// mismos modelos/form que usa ReservationScreen
import '../models/passenger_info.dart';
import '../screens/passengers_form_screen.dart';
import '../models/reservation_create_request.dart'; // por PassengerCreateRequest
import 'homepage_screen.dart';

// Provider para obtener el userId
import '../providers/client_provider.dart';

class EmptyLegReservationScreen extends StatefulWidget {
  final int emptyLegId;

  const EmptyLegReservationScreen({super.key, required this.emptyLegId});

  @override
  State<EmptyLegReservationScreen> createState() =>
      _EmptyLegReservationScreenState();
}

class _EmptyLegReservationScreenState extends State<EmptyLegReservationScreen> {
  final _svc = EmptyLegService();

  late Future<EmptyLegDetailModel> _future;

  // Pasajeros
  List<PassengerInfo> _passengers = [];
  int _passengersCount = 1; // cantidad seleccionada en el control

  // Opciones
  bool lapInfant = false;
  bool dog = false;

  // Flujo
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    _future = _svc.getEmptyLegDetail(widget.emptyLegId);

    // Opcional: si quieres asegurarte de que el provider cargue el perfil aquí
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<ClientProvider>().load();
    // });
  }

  // ================== FORMATOS DE FECHA/HORA ==================
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

  String _formatTimeShort(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'p.m.' : 'a.m.';
    return '$h:$mm $ampm';
  }

  static String _fmtDur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  // Usamos dynamic para no depender de cómo venga exactamente en el modelo
  DateTime? _tryArrivalTime(EmptyLegDetailModel leg) {
    try {
      final dyn = leg as dynamic;
      final val = dyn.arrivalTime;
      if (val is DateTime) return val;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF0000);

    return FutureBuilder<EmptyLegDetailModel>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Empty Leg Reservation',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  snap.error?.toString() ??
                      'Could not load empty leg information.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final leg = snap.data!;
        final dep = leg.departureTime.toLocal();
        final arr = _tryArrivalTime(leg) ?? dep;
        final eft = arr.isAfter(dep)
            ? arr.difference(dep)
            : const Duration(hours: 1);

        // Asegurar que el contador no supere el máximo
        final maxSeats = leg.maxPassengerCount.clamp(1, 999).toInt();
        if (_passengersCount > maxSeats) {
          _passengersCount = maxSeats;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Empty Leg Reservation',
              style: TextStyle(color: red, fontWeight: FontWeight.w800),
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(leg),

                // ===== Itinerary =====
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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
                              title: _formatMonthDay(dep),
                              value: _formatTimeShort(dep),
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
                              value: _formatTimeShort(arr),
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
                                  leg.departureAirportName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  leg.departureAirportName,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.flight,
                            color: Colors.black54,
                            size: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  leg.arrivalAirportName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  leg.arrivalAirportName,
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

                // ===== Passenger selector =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Passengers',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _passengersCount > 1
                                  ? () {
                                      setState(() {
                                        _passengersCount--;
                                        if (_passengers.length >
                                            _passengersCount) {
                                          _passengers = _passengers
                                              .take(_passengersCount)
                                              .toList();
                                        }
                                      });
                                    }
                                  : null,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '$_passengersCount',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _passengersCount < maxSeats
                                  ? () {
                                      setState(() {
                                        _passengersCount++;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
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
                        onPressed: () => _openPassengersForm(leg),
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
                            '${p.name ?? "Passenger"} ${p.lastName ?? (i + 1)}'
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
                  onChanged: (v) {
                    setState(() => lapInfant = v);
                  },
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
                      onPressed: () => _showBreakdown(leg),
                      icon: const Icon(Icons.receipt_long),
                      label: const Text(
                        'View price breakdown',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 90),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(red, leg),
        );
      },
    );
  }

  // ================== HEADER ==================
  Widget _buildHeader(EmptyLegDetailModel leg) {
    final img = leg.aircraftImage ?? '';
    final seats = leg.maxPassengerCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: img.isNotEmpty
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
                  leg.aircraftModel,
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

  // ================== BOTTOM BAR ==================
  Widget _buildBottomBar(Color red, EmptyLegDetailModel leg) {
    final total = leg.finalPrice;

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
                    'Total (empty leg)',
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
                        total.toStringAsFixed(0),
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
                onPressed: _booking ? null : () => _confirmAndBook(leg),
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

  // ================== ACCIONES ==================
  Future<void> _openPassengersForm(EmptyLegDetailModel leg) async {
    final maxPassengers = leg.maxPassengerCount;
    final desiredCount = _passengersCount.clamp(1, maxPassengers);

    final result = await Navigator.of(context).push<List<PassengerInfo>>(
      MaterialPageRoute(
        builder: (_) => PassengersFormScreen(
          passengersCount: desiredCount,
          initialPassengers: _passengers,
        ),
      ),
    );

    if (result != null) {
      setState(() => _passengers = result);
    }
  }

  void _showBreakdown(EmptyLegDetailModel leg) {
    final total = leg.finalPrice;

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
                    '$_passengersCount'
                    '${lapInfant ? ' + lap infant' : ''}',
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Empty leg base price',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    total.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmAndBook(EmptyLegDetailModel leg) async {
    if (_booking) return;

    if (_passengers.length != _passengersCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill passengers info for the selected number of passengers.',
          ),
        ),
      );
      return;
    }

    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm empty leg reservation'),
        content: const Text(
          'Do you want to confirm this empty leg reservation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (shouldContinue != true) return;

    await _book(leg);
  }

  Future<void> _book(EmptyLegDetailModel leg) async {
    if (_passengers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one passenger.')),
      );
      return;
    }

    // Obtener userId desde el provider
    final clientProvider = context.read<ClientProvider>();
    final userId = clientProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We could not identify your user. Please login again and try.',
          ),
        ),
      );
      return;
    }

    setState(() => _booking = true);
    try {
      // Mapear PassengerInfo -> PassengerCreateRequest -> JSON
      final passengerDtos = _passengers.map(_mapPassenger).toList();
      final passengersJson = passengerDtos.map((p) => p.toJson()).toList();

      await _svc.reserveEmptyLeg(
        userId: userId,
        emptyLegFlightId: leg.id,
        price: leg.finalPrice,
        lapChild: lapInfant,
        assistanceAnimal: dog,
        passengers: passengersJson,
        notes: null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empty leg reservation created.')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePageScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error creating reservation. Please try again.'),
        ),
      );
      // Si quieres ver el detalle del error en consola:
      // debugPrint('Error creating empty leg reservation: $e');
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  // ================== HELPERS ==================
  PassengerCreateRequest _mapPassenger(PassengerInfo p) {
    final firstName = (p.name ?? '').trim();
    final middleName = (p.middleName ?? '').trim();
    final lastName = (p.lastName ?? '').trim();
    final passport = (p.passport ?? '').trim().toUpperCase();
    final nationality = (p.nationality ?? '').trim();
    final dob = p.dateOfBirth ?? DateTime(2000, 1, 1);
    final genderString = p.gender.apiValue;

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
}

// ================== Widgets auxiliares ==================

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
