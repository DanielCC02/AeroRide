// lib/screens/reservations/passenger_details_screen.dart
// Mapea PassengerInfo -> PassengerDetailDto de forma tolerante (sin asumir getters fijos).

import 'package:flutter/material.dart';
import '../../models/passenger_detail_dto.dart';
import '../../models/passenger_info.dart';
import '../../services/passenger_service.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final int reservationId;
  final List<PassengerInfo> initialPassengers;

  const PassengerDetailsScreen({
    super.key,
    required this.reservationId,
    required this.initialPassengers,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  bool _saving = false;
  late List<_FormPax> _forms;

  @override
  void initState() {
    super.initState();
    _forms = widget.initialPassengers.map((p) => _FormPax.fromUi(p)).toList();
  }

  Future<bool> _onWillPop() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Discard passengers?'),
        content: const Text(
          'If you go back now, your reservation will be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard == true;
  }

  @override
  Widget build(BuildContext context) {
    // Cacheamos el navigator para no usar context después de async gaps
    final navigator = Navigator.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Si ya se hizo pop por otra razón, no hacemos nada
        if (didPop) {
          return;
        }

        // Reutilizamos tu lógica existente de _onWillPop()
        _onWillPop().then((shouldPop) {
          if (!mounted) {
            return;
          }

          // Si el usuario confirma "Discard", hacemos el pop manualmente
          if (shouldPop) {
            // Usamos pop() sin resultado explícito para mantener el mismo comportamiento
            // que con WillPopScope (el caller recibe null, y solo trata true como éxito).
            navigator.pop();
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Passengers'), centerTitle: true),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _forms.length,
          itemBuilder: (_, i) {
            final f = _forms[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Passenger ${i + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _txt('Name *', f.name, (v) => f.name = v),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _txt(
                            'Middle name',
                            f.middleName,
                            (v) => f.middleName = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _txt(
                            'Last name *',
                            f.lastName,
                            (v) => f.lastName = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _txt(
                            'Passport *',
                            f.passport,
                            (v) => f.passport = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _txt(
                            'Nationality *',
                            f.nationality,
                            (v) => f.nationality = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final now = DateTime.now();
                              final d = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                ),
                                initialDate: f.dateOfBirth,
                              );
                              if (d != null) {
                                setState(() => f.dateOfBirth = d);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date of birth *',
                              ),
                              child: Text(
                                '${f.dateOfBirth.year}-'
                                '${f.dateOfBirth.month.toString().padLeft(2, '0')}-'
                                '${f.dateOfBirth.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: f.gender,
                            items: const [
                              DropdownMenuItem(
                                value: 'Masculino',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Femenino',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem(
                                value: 'Otro',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (v) => setState(() => f.gender = v),
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Complete reservation'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    // Cacheamos el messenger y navigator ANTES de cualquier await
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    for (final f in _forms) {
      if (f.name.trim().isEmpty ||
          f.lastName.trim().isEmpty ||
          f.passport.trim().isEmpty ||
          f.nationality.trim().isEmpty) {
        _snack(messenger, 'Please fill in all required fields.');
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final payload = _forms
          .map(
            (f) => PassengerDetailDto(
              reservationId: widget.reservationId,
              name: f.name.trim(),
              middleName: f.middleName.trim().isEmpty
                  ? null
                  : f.middleName.trim(),
              lastName: f.lastName.trim(),
              passport: f.passport.trim(),
              dateOfBirth: DateTime(
                f.dateOfBirth.year,
                f.dateOfBirth.month,
                f.dateOfBirth.day,
              ),
              gender: f.gender,
              nationality: f.nationality.trim(),
            ),
          )
          .toList();

      await PassengerService().createForReservation(
        widget.reservationId,
        payload,
      );
      if (!mounted) {
        return;
      }
      navigator.pop<bool>(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _snack(messenger, 'Could not save passengers. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _txt(String label, String initial, ValueChanged<String> onChanged) {
    final ctrl = TextEditingController(text: initial);
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }

  void _snack(ScaffoldMessengerState messenger, String msg) {
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// Estructura de edición local
class _FormPax {
  String name;
  String middleName;
  String lastName;
  String passport;
  String nationality;
  DateTime dateOfBirth;
  String? gender;

  _FormPax({
    required this.name,
    required this.middleName,
    required this.lastName,
    required this.passport,
    required this.nationality,
    required this.dateOfBirth,
    required this.gender,
  });

  /// Mapea desde tu `PassengerInfo` sin asumir getters específicos.
  /// - Si existen `firstName/lastName/middleName`, los usa.
  /// - Si no, intenta `fullName` o `name` y lo separa.
  /// - Lee `passport`, `birthDate`, `nationality`, `gender` si existen.
  factory _FormPax.fromUi(PassengerInfo p) {
    final dyn = p as dynamic;

    String? readStr(String prop) {
      try {
        switch (prop) {
          case 'firstName':
            return dyn.firstName as String?;
          case 'middleName':
            return dyn.middleName as String?;
          case 'lastName':
            return dyn.lastName as String?;
          case 'fullName':
            return dyn.fullName as String?;
          case 'name':
            return dyn.name as String?;
          case 'passport':
            return dyn.passport as String?;
          case 'nationality':
            return dyn.nationality as String?;
          case 'gender':
            return dyn.gender as String?;
        }
      } catch (_) {}
      return null;
    }

    DateTime? readDate(String prop) {
      try {
        switch (prop) {
          case 'birthDate':
            final raw = dyn.birthDate;
            if (raw is DateTime) return raw;
            if (raw is String) return DateTime.tryParse(raw);
            return null;
        }
      } catch (_) {}
      return null;
    }

    // 1) Nombres separados si existen
    String fname = readStr('firstName') ?? '';
    String mname = readStr('middleName') ?? '';
    String lname = readStr('lastName') ?? '';

    // 2) Si no tenemos nombres separados, partir de fullName/name
    if (fname.isEmpty && lname.isEmpty) {
      final full = readStr('fullName') ?? readStr('name') ?? '';
      final parts = full.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        fname = parts.first;
        if (parts.length == 1) {
          lname = '';
        } else if (parts.length == 2) {
          lname = parts.last;
        } else {
          mname = parts.sublist(1, parts.length - 1).join(' ');
          lname = parts.last;
        }
      }
    }

    // 3) Otros campos
    final passport = readStr('passport') ?? '';
    final nationality = readStr('nationality') ?? '';
    final gender = readStr('gender');
    final dob = readDate('birthDate') ?? DateTime(2000, 1, 1);

    return _FormPax(
      name: fname,
      middleName: mname,
      lastName: lname,
      passport: passport,
      nationality: nationality,
      dateOfBirth: dob,
      gender: gender,
    );
  }
}
