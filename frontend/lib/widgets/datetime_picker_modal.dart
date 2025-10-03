import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DateTimePickerModal extends StatefulWidget {
  final void Function(DateTime) onSelected;
  final DateTime? initialDateTime;
  final String? routeTitle; // ej: "MRPV (SYQ) → Nosara"

  const DateTimePickerModal({
    super.key,
    required this.onSelected,
    this.initialDateTime,
    this.routeTitle,
  });

  @override
  State<DateTimePickerModal> createState() => _DateTimePickerModalState();
}

class _DateTimePickerModalState extends State<DateTimePickerModal> {
  late DateTime _minDate; // redondeado al minuto
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _minDate = DateTime(now.year, now.month, now.day, now.hour, now.minute);

    final init = widget.initialDateTime ?? now;
    final safeInit = init.isBefore(_minDate) ? _minDate : init;

    _selectedDay  = DateTime(safeInit.year, safeInit.month, safeInit.day);
    _focusedDay   = _selectedDay;
    _selectedTime = TimeOfDay(hour: safeInit.hour, minute: safeInit.minute);
  }

  DateTime get _combinedDateTime =>
      DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, _selectedTime.hour, _selectedTime.minute);

  void _onDone() {
    final dt = _combinedDateTime.isBefore(_minDate) ? _minDate : _combinedDateTime;
    widget.onSelected(dt);
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height * 0.80; // hoja alta, como el mockup
    final monthLabel = _monthName(_focusedDay.month);

    return SafeArea(
      top: false,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Encabezado: logo + ruta
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Row(
                children: [
                  // tu logo
                  Image.asset('assets/images/logo.jpg', height: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.routeTitle ?? 'Select date',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Header del calendario (mes en minúsculas + flechas)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                    }),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      '$monthLabel ${_focusedDay.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                    }),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            // Calendario
            TableCalendar(
              firstDay: _minDate,
              lastDay: _minDate.add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              locale: 'en_US', // o 'es_CR' si lo prefieres
              headerVisible: false,
              selectedDayPredicate: (day) =>
                  day.year == _selectedDay.year &&
                  day.month == _selectedDay.month &&
                  day.day == _selectedDay.day,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = DateTime(selected.year, selected.month, selected.day);
                  _focusedDay  = _selectedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.w600),
                weekendStyle: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 8),

            // Campo "Time" y rueda de hora estilo iOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Time', style: TextStyle(color: Colors.grey.shade700)),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_formatTime(_selectedTime)),
            ),
            SizedBox(
              height: 140,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false,
                initialDateTime: DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute),
                onDateTimeChanged: (dt) => setState(() {
                  _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
                }),
              ),
            ),

            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Choose your preferred departure time, prices may vary.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 12),

            // Done
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'january','february','march','april','may','june',
      'july','august','september','october','november','december'
    ];
    return months[m - 1];
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final mm = t.minute.toString().padLeft(2, '0');
    final ampm = t.period == DayPeriod.pm ? 'p.m.' : 'a.m.';
    return '$h:$mm $ampm';
  }
}
