// lib/screens/passengers_form_screen.dart
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

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

  late final List<TextEditingController> _firstNameCtrls;
  late final List<TextEditingController> _middleNameCtrls;
  late final List<TextEditingController> _lastNameCtrls;
  late final List<TextEditingController> _passportCtrls;
  late final List<TextEditingController> _nationalityCtrls;

  late final List<TextEditingController> _birthTextCtrls; // visible en UI
  late final List<DateTime?> _birthDates; // valor real

  late final List<PassengerGender?> _genderValues;

  @override
  void initState() {
    super.initState();
    final n = widget.passengersCount;

    _firstNameCtrls = List.generate(n, (_) => TextEditingController());
    _middleNameCtrls = List.generate(n, (_) => TextEditingController());
    _lastNameCtrls = List.generate(n, (_) => TextEditingController());
    _passportCtrls = List.generate(n, (_) => TextEditingController());
    _nationalityCtrls = List.generate(n, (_) => TextEditingController());

    _birthTextCtrls = List.generate(n, (_) => TextEditingController());
    _birthDates = List<DateTime?>.filled(n, null);

    _genderValues = List<PassengerGender?>.filled(n, null);

    // Prefill si llega información previa
    final init = widget.initialPassengers;
    if (init != null && init.isNotEmpty) {
      for (int i = 0; i < n && i < init.length; i++) {
        final p = init[i];
        _firstNameCtrls[i].text = p.name ?? '';
        _middleNameCtrls[i].text = p.middleName ?? '';
        _lastNameCtrls[i].text = p.lastName ?? '';
        _passportCtrls[i].text = p.passport ?? '';
        _nationalityCtrls[i].text = p.nationality ?? '';

        final dob = p.dateOfBirth;
        if (dob != null) {
          _birthDates[i] = dob;
          _birthTextCtrls[i].text = _fmtDate(dob);
        }

        _genderValues[i] = p.gender;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _firstNameCtrls) {
      c.dispose();
    }
    for (final c in _middleNameCtrls) {
      c.dispose();
    }
    for (final c in _lastNameCtrls) {
      c.dispose();
    }
    for (final c in _passportCtrls) {
      c.dispose();
    }
    for (final c in _nationalityCtrls) {
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

  void _openCountryPicker(int index) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      favorite: const ['CR', 'PA', 'NI', 'HN', 'GT', 'MX', 'US'],
      onSelect: (Country country) {
        setState(() {
          // Usamos el nombre del país como Nationality
          _nationalityCtrls[index].text = country.name;
        });
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Valida fechas y género por cada pasajero
    for (int i = 0; i < widget.passengersCount; i++) {
      if (_birthDates[i] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select birth date for passenger ${i + 1}'),
          ),
        );
        return;
      }
      if (_genderValues[i] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select gender for passenger ${i + 1}'),
          ),
        );
        return;
      }
    }

    final result = <PassengerInfo>[];
    for (int i = 0; i < widget.passengersCount; i++) {
      final middle = _middleNameCtrls[i].text.trim();
      result.add(
        PassengerInfo(
          name: _firstNameCtrls[i].text.trim(),
          middleName: middle.isEmpty ? null : middle,
          lastName: _lastNameCtrls[i].text.trim(),
          passport: _passportCtrls[i].text.trim().toUpperCase(),
          nationality: _nationalityCtrls[i].text.trim(),
          dateOfBirth: DateTime(
            _birthDates[i]!.year,
            _birthDates[i]!.month,
            _birthDates[i]!.day,
          ),
          gender: _genderValues[i]!,
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

                  // First name
                  TextFormField(
                    controller: _firstNameCtrls[i],
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'First name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  // Middle name (optional)
                  TextFormField(
                    controller: _middleNameCtrls[i],
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Middle name (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Last name
                  TextFormField(
                    controller: _lastNameCtrls[i],
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Last name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  // Nationality (con country picker)
                  TextFormField(
                    controller: _nationalityCtrls[i],
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Nationality',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    onTap: () => _openCountryPicker(i),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  // Gender
                  DropdownButtonFormField<PassengerGender>(
                    initialValue: _genderValues[i],
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: PassengerGender.masculino,
                        child: Text('Male'),
                      ),
                      DropdownMenuItem(
                        value: PassengerGender.femenino,
                        child: Text('Female'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _genderValues[i] = value;
                      });
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  // Birth date
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

                  // Passport
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

  String _fmtDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$dd';
  }
}
