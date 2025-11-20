// lib/widgets/search_form.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../services/airport_service.dart';
import '../models/airport_model.dart';
import '../models/search_criteria.dart';
import '../screens/plane_list_screen.dart';

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

enum TripType { oneWay, roundTrip }

class _SearchFormState extends State<SearchForm> {
  // ----- UI state -----
  TripType tripType = TripType.oneWay;

  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _fromFocus = FocusNode();
  final _toFocus = FocusNode();

  DateTime? _departure; // fecha+hora ida
  DateTime? _returnDateTime; // fecha+hora vuelta (solo round trip)
  int _passengers = 1;

  // ----- Búsqueda dinámica -----
  List<Airport> _fromResults = [];
  List<Airport> _toResults = [];

  Airport? _selectedFrom;
  Airport? _selectedTo;

  Timer? _debounceFrom;
  Timer? _debounceTo;

  @override
  void initState() {
    super.initState();
    _searchFrom('');
    _searchTo('');

    _fromCtrl.addListener(() {
      _debounceFrom?.cancel();
      _debounceFrom = Timer(const Duration(milliseconds: 400), () {
        final q = _fromCtrl.text.trim();
        if (q.length >= 2) {
          _searchFrom(q);
        } else {
          setState(() => _fromResults = []);
        }
      });
    });

    _toCtrl.addListener(() {
      _debounceTo?.cancel();
      _debounceTo = Timer(const Duration(milliseconds: 400), () {
        final q = _toCtrl.text.trim();
        if (q.length >= 2) {
          _searchTo(q);
        } else {
          setState(() => _toResults = []);
        }
      });
    });
  }

  @override
  void dispose() {
    _debounceFrom?.cancel();
    _debounceTo?.cancel();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    super.dispose();
  }

  // ----- Services -----
  Future<void> _searchFrom(String q) async {
    if (q.trim().length < 2) {
      if (mounted) setState(() => _fromResults = []);
      return;
    }
    final res = await AirportService.searchAirports(q, limit: 5);
    if (!mounted) return;
    setState(() => _fromResults = res);
  }

  Future<void> _searchTo(String q) async {
    if (q.trim().length < 2) {
      if (mounted) setState(() => _toResults = []);
      return;
    }
    final res = await AirportService.searchAirports(q, limit: 5);
    if (!mounted) return;
    setState(() => _toResults = res);
  }

  // ==========================
  // Reglas y utilidades
  // ==========================

  bool get _hasFromTo => _selectedFrom != null && _selectedTo != null;

  bool get _isInternationalDestination {
    final to = _selectedTo;
    if (to == null) return false;
    final c = (to.country).trim().toLowerCase();
    final isCR = c.contains('costa') && c.contains('rica');
    return !isCR;
  }

  TimeOfDay? _parseHHmm(String? hhmmss) {
    if (hhmmss == null || hhmmss.trim().isEmpty) return null;
    final parts = hhmmss.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  int _todToMin(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Ventana de tiempo permitida (minutos desde medianoche)
  /// - 24h si opening/closing nulos/vacíos => 00:00..23:59
  /// - Si hay horarios => [Opening .. (Closing - 60min)]
  ({int startMin, int endMin})? _allowedWindowFor(Airport a) {
    final open = _parseHHmm(a.openingTime);
    final close = _parseHHmm(a.closingTime);

    // 24h si no hay datos
    final is24 = (open == null && close == null);
    if (is24) return (startMin: 0, endMin: 23 * 60 + 59);

    if (open == null || close == null) {
      // Si falta uno, asumimos 24h (defensivo)
      return (startMin: 0, endMin: 23 * 60 + 59);
    }

    final start = _todToMin(open);
    final end = (_todToMin(close) - 60).clamp(0, 23 * 60 + 59);
    if (end < start) return null; // ventana inválida

    return (startMin: start, endMin: end);
  }

  DateTime _merge(DateTime date, TimeOfDay t) =>
      DateTime(date.year, date.month, date.day, t.hour, t.minute);

  String _fmtRange(int startMin, int endMin) {
    String f(int m) =>
        '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
    return '${f(startMin)} – ${f(endMin)}';
  }

  // ==========================
  // Pickers (fecha + reloj Material con validación)
  // ==========================
  Future<void> _pickDateTime({required bool isReturn}) async {
    if (!_hasFromTo) {
      _snack('Please select both airports first.');
      return;
    }

    // Aeropuerto que manda en el horario:
    // - Ida: FROM
    // - Vuelta: TO (sale desde el destino)
    final airportForTime = isReturn ? _selectedTo! : _selectedFrom!;

    // Regla internacional: destino internacional → fecha mínima en 4 días
    final now = DateTime.now();
    final minDate = _isInternationalDestination
        ? DateTime(now.year, now.month, now.day).add(const Duration(days: 4))
        : now;

    final initialBase = isReturn
        ? (_returnDateTime ?? _departure ?? now)
        : (_departure ?? now);
    final initialDate = initialBase.isBefore(minDate) ? minDate : initialBase;

    // 1) Fecha
    final date = await showDatePicker(
      context: context,
      firstDate: minDate,
      lastDate: DateTime(now.year + 1),
      initialDate: initialDate,
    );
    if (date == null || !mounted) return;

    // 2) Ventana horaria
    final win = _allowedWindowFor(airportForTime);
    if (win == null) {
      await _showInvalidTimeDialog(
        airportName: airportForTime.name,
        rangeText: 'No available window',
      );
      return;
    }

    final rangeText = _fmtRange(win.startMin, win.endMin);

    // 3) Reloj (showTimePicker) con validación dura y snap a ventana
    final picked = await _pickValidatedTime(
      airportName: airportForTime.name,
      initial: TimeOfDay.fromDateTime(initialBase),
      startMin: win.startMin,
      endMin: win.endMin,
      rangeText: rangeText,
      help: 'Available: $rangeText',
    );
    if (picked == null || !mounted) return;

    final pickedDt = _merge(date, picked);

    if (isReturn) {
      if (_departure != null && pickedDt.isBefore(_departure!)) {
        await _showInvalidTimeDialog(
          airportName: airportForTime.name,
          rangeText: rangeText,
          customMsg: 'Return must be after departure.',
        );
        return;
      }
      setState(() => _returnDateTime = pickedDt);
    } else {
      setState(() => _departure = pickedDt);
      // Si hay return inválido, limpiar
      if (_returnDateTime != null && _returnDateTime!.isBefore(pickedDt)) {
        setState(() => _returnDateTime = null);
      }
    }
  }

  /// Muestra el reloj; si el usuario elige fuera del rango permitido,
  /// muestra un DIÁLOGO con nombre de aeropuerto y su rango y reabre
  /// el reloj con la hora válida más cercana preseleccionada.
  Future<TimeOfDay?> _pickValidatedTime({
    required String airportName,
    required TimeOfDay initial,
    required int startMin,
    required int endMin,
    required String rangeText,
    String? help,
  }) async {
    TimeOfDay init = initial;

    while (true) {
      final t = await showTimePicker(
        context: context,
        initialTime: init,
        helpText: 'Select time',
        cancelText: 'Cancel',
        confirmText: 'Confirm',
        builder: (ctx, child) {
          return Theme(
            data: Theme.of(ctx).copyWith(
              timePickerTheme: TimePickerThemeData(
                helpTextStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              textTheme: Theme.of(ctx).textTheme,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: child ?? const SizedBox.shrink()),
                if (help != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      help,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
              ],
            ),
          );
        },
      );

      if (t == null) return null;

      final m = _todToMin(t);
      if (m < startMin || m > endMin) {
        // Hora inválida → diálogo y snap
        final nearMin = (m < startMin) ? startMin : endMin;
        final near = TimeOfDay(hour: (nearMin ~/ 60), minute: (nearMin % 60));

        await _showInvalidTimeDialog(
          airportName: airportName,
          rangeText: rangeText,
        );
        if (!mounted) return null;

        // Reabrir reloj con valor sugerido
        init = near;
        continue; // vuelve a mostrar showTimePicker
      }

      return t;
    }
  }

  Future<void> _showInvalidTimeDialog({
    required String airportName,
    required String rangeText,
    String? customMsg,
  }) async {
    final msg =
        customMsg ??
        'The selected time is not available.\n'
            '$airportName operates from $rangeText.';
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invalid time'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ----- Acciones -----
  void _swapAirports() {
    final tmpAirport = _selectedFrom;
    final tmpText = _fromCtrl.text;
    setState(() {
      _selectedFrom = _selectedTo;
      _fromCtrl.text = _toCtrl.text;
      _selectedTo = tmpAirport;
      _toCtrl.text = tmpText;

      // Invalida horarios elegidos al cambiar aeropuertos
      _departure = null;
      _returnDateTime = null;
    });
  }

  void _onSearch() {
    if (_selectedFrom == null || _selectedTo == null) {
      _snack('Please select both airports.');
      return;
    }
    if (_departure == null) {
      _snack('Please select date & time.');
      return;
    }
    if (tripType == TripType.roundTrip) {
      if (_returnDateTime == null) {
        _snack('Please select the return date & time.');
        return;
      }
      if (_returnDateTime!.isBefore(_departure!)) {
        _snack('Return must be after departure.');
        return;
      }
    }
    if (_passengers < 1) {
      _snack('Passengers must be at least 1.');
      return;
    }

    final criteria = SearchCriteria(
      from: _selectedFrom!,
      to: _selectedTo!,
      passengers: _passengers,
      departure: _departure!,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaneListScreen(criteria: criteria)),
    );
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  // ====== Widgets ======

  Widget _suggestionTile(Airport a, void Function() onTap) {
    final countryCity = () {
      final c = a.country.trim();
      final city = a.city.trim();
      if (c.isEmpty && city.isEmpty) return '';
      if (c.isEmpty) return city;
      if (city.isEmpty) return c;
      return '$c - $city';
    }();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              countryCity,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: '${a.name} - ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: a.codeIATA,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldWithSuggestions({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required List<Airport> results,
    required void Function(Airport a) onPick,
  }) {
    final show = focusNode.hasFocus && results.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: label,
            hintText: label,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onSubmitted: (_) {
            if (results.isNotEmpty) onPick(results.first);
          },
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(top: 6),
          constraints: const BoxConstraints(maxHeight: 140),
          child: show
              ? Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: results.length.clamp(0, 2),
                      itemBuilder: (_, i) {
                        final a = results[i];
                        return _suggestionTile(a, () => onPick(a));
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _tripTypeTabs() {
    bool on(TripType t) => tripType == t;
    ButtonStyle style(bool selected) => ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: selected ? Colors.red : Colors.white,
      foregroundColor: selected ? Colors.white : Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE9E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: style(on(TripType.oneWay)),
              onPressed: () => setState(() {
                tripType = TripType.oneWay;
                _returnDateTime = null; // limpiar vuelta
              }),
              child: const Text('One-way'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              style: style(on(TripType.roundTrip)),
              onPressed: () => setState(() => tripType = TripType.roundTrip),
              child: const Text('Round trip'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final text = value == null
        ? label
        : '${value.year.toString().padLeft(4, '0')}-'
              '${value.month.toString().padLeft(2, '0')}-'
              '${value.day.toString().padLeft(2, '0')} '
              '${value.hour.toString().padLeft(2, '0')}:'
              '${value.minute.toString().padLeft(2, '0')}';

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    );
    final disabledColor = Colors.black45;

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.55,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: enabled ? null : disabledColor),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: baseBorder,
              enabledBorder: baseBorder,
              disabledBorder: baseBorder,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  size: 18,
                  color: enabled ? Colors.black54 : disabledColor,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(text)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passengersField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passengers',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _passengers > 1
                    ? () => setState(() => _passengers--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_passengers',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _passengers++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final canPickDeparture = _selectedFrom != null && _selectedTo != null;
    final canPickReturn = canPickDeparture && tripType == TripType.roundTrip;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----- Banner -----
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/main_menu_pic.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, size: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ----- Título "Flight" centrado y rojo -----
          const Center(
            child: Text(
              'Flight',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ----- Tabs One-way / Round trip -----
          _tripTypeTabs(),
          const SizedBox(height: 12),

          // ----- From (arriba) / botón swap / To (abajo) -----
          _fieldWithSuggestions(
            label: 'From',
            controller: _fromCtrl,
            focusNode: _fromFocus,
            results: _fromResults,
            onPick: (a) async {
              setState(() {
                _selectedFrom = a;
                _fromCtrl.text = '${a.name} - ${a.codeIATA}';
                _fromResults = []; // ⬅️ cerrar sugerencias
                _departure = null;
                _returnDateTime = null;
              });
              _fromFocus.unfocus();
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              height: 40,
              width: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: IconButton(
                onPressed: _swapAirports,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Swap',
              ),
            ),
          ),
          const SizedBox(height: 8),
          _fieldWithSuggestions(
            label: 'To',
            controller: _toCtrl,
            focusNode: _toFocus,
            results: _toResults,
            onPick: (a) async {
              setState(() {
                _selectedTo = a;
                _toCtrl.text = '${a.name} - ${a.codeIATA}';
                _toResults = []; // ⬅️ cerrar sugerencias
                _departure = null;
                _returnDateTime = null;
              });
              _toFocus.unfocus();
            },
          ),
          const SizedBox(height: 12),

          // ----- Date & time (ida) -----
          _dateTimeField(
            label: 'Date and time',
            value: _departure,
            enabled: canPickDeparture,
            onTap: () => _pickDateTime(isReturn: false),
          ),
          const SizedBox(height: 12),

          // ----- Return (solo round trip) -----
          if (tripType == TripType.roundTrip) ...[
            _dateTimeField(
              label: 'Return date and time',
              value: _returnDateTime,
              enabled: canPickReturn,
              onTap: () => _pickDateTime(isReturn: true),
            ),
            const SizedBox(height: 12),
          ],

          // ----- Passengers -----
          _passengersField(),
          const SizedBox(height: 16),

          // ----- Botón Search -----
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: _onSearch,
              child: const Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
