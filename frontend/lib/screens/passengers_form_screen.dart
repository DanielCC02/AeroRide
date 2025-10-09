import 'package:flutter/material.dart';
import '../models/passenger_info.dart';

/// PassengersFormScreen
/// ---------------------------------------------------------------------------
/// Formulario dinámico para capturar la información de los pasajeros.
/// - La cantidad de formularios depende de `passengersCount`.
/// - Cada pasajero requiere: Nombre completo, Fecha de nacimiento, Pasaporte.
/// - Valida todos los campos.
/// - Devuelve `List<PassengerInfo>` con `Navigator.pop(result)`.
///
/// PERSISTENCIA:
/// - Si se provee `initialPassengers`, el formulario se prellena.
/// - Al volver a abrir desde Reservation, se conserva lo ya ingresado.
///
/// UI:
/// - Campos con `OutlineInputBorder`.
/// - Selector de fecha con `showDatePicker`.
/// - Botón inferior fijo “Done” (rojo).
///
/// FUTURO:
/// - Validar formato de pasaporte según país.
/// - Internacionalización de labels y formato de fecha.
class PassengersFormScreen extends StatefulWidget {
  final int passengersCount;
  final List<PassengerInfo>? initialPassengers;

  const PassengersFormScreen({
    super.key,
    required this.passengersCount,
    this.initialPassengers,
  });

  @override
  State<PassengersFormScreen> createState() => _PassengersFormScreenState();
}

class _PassengersFormScreenState extends State<PassengersFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final List<TextEditingController> _nameCtrls;
  late final List<TextEditingController> _passportCtrls;
  late final List<TextEditingController> _birthTextCtrls; // visible en UI
  late final List<DateTime?> _birthDates;                 // valor real

  @override
  void initState() {
    super.initState();
    final n = widget.passengersCount;

    _nameCtrls      = List.generate(n, (_) => TextEditingController());
    _passportCtrls  = List.generate(n, (_) => TextEditingController());
    _birthTextCtrls = List.generate(n, (_) => TextEditingController());
    _birthDates     = List<DateTime?>.filled(n, null);

    // Prefill si llega información previa
    final init = widget.initialPassengers;
    if (init != null && init.isNotEmpty) {
      for (int i = 0; i < n && i < init.length; i++) {
        _nameCtrls[i].text      = init[i].fullName;
        _passportCtrls[i].text  = init[i].passport;
        _birthDates[i]          = init[i].birthDate;
        _birthTextCtrls[i].text = _fmtDate(init[i].birthDate);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _nameCtrls) c.dispose();
    for (final c in _passportCtrls) c.dispose();
    for (final c in _birthTextCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate(int i) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 120, 1, 1);
    final last = now;
    final initial = _birthDates[i] ?? DateTime(now.year - 30, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) || initial.isAfter(last) ? last : initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      setState(() {
        _birthDates[i] = picked;
        _birthTextCtrls[i].text = _fmtDate(picked); // visible
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Valida fechas
    for (int i = 0; i < _birthDates.length; i++) {
      if (_birthDates[i] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select birth date for passenger ${i + 1}')),
        );
        return;
      }
    }

    final result = <PassengerInfo>[];
    for (int i = 0; i < widget.passengersCount; i++) {
      result.add(
        PassengerInfo(
          fullName: _nameCtrls[i].text.trim(),
          birthDate: _birthDates[i]!,
          passport: _passportCtrls[i].text.trim().toUpperCase(),
        ),
      );
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF0000);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Passengers Information',
          style: TextStyle(
            color: red,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: _formKey,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          itemCount: widget.passengersCount,
          itemBuilder: (_, i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passenger ${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrls[i],
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    readOnly: true,
                    controller: _birthTextCtrls[i],
                    onTap: () => _pickBirthDate(i),
                    decoration: const InputDecoration(
                      labelText: 'Birth date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passportCtrls[i],
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Passport number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        color: Colors.white,
        child: SizedBox(
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
            onPressed: _submit,
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$dd';
  }
}
