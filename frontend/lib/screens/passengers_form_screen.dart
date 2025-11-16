import 'package:flutter/material.dart';
import '../models/passenger_info.dart';

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
  late final List<DateTime?> _birthDates; // valor real

  @override
  void initState() {
    super.initState();
    final n = widget.passengersCount;

    _nameCtrls = List.generate(n, (_) => TextEditingController());
    _passportCtrls = List.generate(n, (_) => TextEditingController());
    _birthTextCtrls = List.generate(n, (_) => TextEditingController());
    _birthDates = List<DateTime?>.filled(n, null);

    // Prefill si llega información previa
    final init = widget.initialPassengers;
    if (init != null && init.isNotEmpty) {
      for (int i = 0; i < n && i < init.length; i++) {
        _nameCtrls[i].text = _pName(init[i]);
        _passportCtrls[i].text = _pPassport(init[i]) ?? '';
        final dob = _pDob(init[i]);
        _birthDates[i] = dob;
        _birthTextCtrls[i].text = _fmtDate(dob);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _nameCtrls) {
      c.dispose();
    }
    for (final c in _passportCtrls) {
      c.dispose();
    }
    for (final c in _birthTextCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthDate(int i) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 120, 1, 1);
    final last = now;
    final initial =
        _birthDates[i] ?? DateTime(now.year - 30, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: (initial.isBefore(first) || initial.isAfter(last))
          ? last
          : initial,
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
          SnackBar(
            content: Text('Please select birth date for passenger ${i + 1}'),
          ),
        );
        return;
      }
    }

    final result = <PassengerInfo>[];
    for (int i = 0; i < widget.passengersCount; i++) {
      // La mayoría de tus usos esperan: name + dateOfBirth (+ passport?)
      // Ajusta aquí si tu constructor difiere.
      result.add(
        PassengerInfo(
          name: _nameCtrls[i].text.trim(),
          dateOfBirth: _birthDates[i]!,
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
          style: TextStyle(color: red, fontWeight: FontWeight.w800),
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
                  Text(
                    'Passenger ${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
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
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  // ================= Helpers para leer initialPassengers sin romper tipado
  String _pName(PassengerInfo p) {
    try {
      final s = (p as dynamic).name as String?;
      if (s != null) return s;
    } catch (_) {}
    try {
      final s = (p as dynamic).fullName as String?;
      if (s != null) return s;
    } catch (_) {}
    try {
      final m = (p as dynamic).toJson() as Map<String, dynamic>;
      final s = m['name'] ?? m['fullName'];
      if (s != null) return s.toString();
    } catch (_) {}
    return '';
  }

  DateTime _pDob(PassengerInfo p) {
    try {
      final d = (p as dynamic).dateOfBirth as DateTime?;
      if (d != null) return d;
    } catch (_) {}
    try {
      final d = (p as dynamic).birthDate as DateTime?;
      if (d != null) return d;
    } catch (_) {}
    try {
      final m = (p as dynamic).toJson() as Map<String, dynamic>;
      final v = m['dateOfBirth'] ?? m['birthDate'];
      if (v is DateTime) return v;
      if (v is String) {
        final dt = DateTime.tryParse(v);
        if (dt != null) return dt;
      }
    } catch (_) {}
    return DateTime(2000, 1, 1);
  }

  String? _pPassport(PassengerInfo p) {
    try {
      return (p as dynamic).passport as String?;
    } catch (_) {}
    try {
      final m = (p as dynamic).toJson() as Map<String, dynamic>;
      final v = m['passport'];
      return v?.toString();
    } catch (_) {}
    return null;
  }

  String _fmtDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$dd';
  }
}
