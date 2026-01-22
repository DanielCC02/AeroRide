import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';

class UpdatePersonalInfoSheet extends StatefulWidget {
  final UserModel initial;

  const UpdatePersonalInfoSheet({
    super.key,
    required this.initial,
  });

  @override
  State<UpdatePersonalInfoSheet> createState() =>
      _UpdatePersonalInfoSheetState();
}

class _UpdatePersonalInfoSheetState extends State<UpdatePersonalInfoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _service = UserService();

  late final TextEditingController _name;
  late final TextEditingController _lastName;
  late final TextEditingController _phoneLocal;

  bool _saving = false;
  String? _error;

  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.name);
    _lastName = TextEditingController(text: widget.initial.lastName);

    // Si viene algo tipo "+506 22222222", intentamos separar.
    final raw = widget.initial.phoneNumber.trim();
    final parts = raw.split(' ');
    if (raw.startsWith('+') && parts.isNotEmpty) {
      // local = el resto
      _phoneLocal = TextEditingController(text: parts.skip(1).join(' ').trim());
    } else {
      _phoneLocal = TextEditingController(text: raw);
    }

    // Default: CR (Costa Rica) si no sabemos, porque estás en CR ahora mismo.
    // Si después querés mapear por widget.initial.country, lo hacemos.
    _selectedCountry = CountryParser.parseCountryCode('CR');
  }

  @override
  void dispose() {
    _name.dispose();
    _lastName.dispose();
    _phoneLocal.dispose();
    super.dispose();
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (c) {
        setState(() => _selectedCountry = c);
      },
    );
  }

  String _buildPhone() {
    final code = _selectedCountry?.phoneCode ?? '506';
    final local = _phoneLocal.text.trim();
    return '+$code $local'.trim();
  }

  Future<void> _save() async {
    setState(() => _error = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final updated = await _service.updateMyProfile(
        name: _name.text.trim(),
        lastName: _lastName.text.trim(),
        phoneNumber: _buildPhone(),
      );

      if (!mounted) return;
      Navigator.of(context).pop<UserModel>(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final height = MediaQuery.of(context).size.height;

    // ✅ “Full screen” feel: 92% del alto
    return SizedBox(
      height: height * 0.92,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Update personal info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'You can edit your basic information here.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(
                              labelText: 'First name',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Required';
                              if (v.trim().length > 50)
                                return 'Max 50 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lastName,
                            decoration: const InputDecoration(
                              labelText: 'Last name',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Required';
                              if (v.trim().length > 50)
                                return 'Max 50 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // ✅ Phone: Country code selector + local number
                          Row(
                            children: [
                              InkWell(
                                onTap: _pickCountry,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 56,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedCountry?.flagEmoji ?? '🇨🇷',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+${_selectedCountry?.phoneCode ?? '506'}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneLocal,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone number',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Required';
                                    if (v.trim().length < 6) return 'Too short';
                                    return null;
                                  },
                                  onFieldSubmitted: (_) =>
                                      _saving ? null : _save(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
