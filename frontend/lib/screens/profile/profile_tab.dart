import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../screens/legal_document_screen.dart';
import '../../widgets/profile/update_personal_info_sheet.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static const String _termsUrl =
      'https://aeroridetest.blob.core.windows.net/legal/terms-of-use-2026-01.pdf';
  static const String _privacyUrl =
      'https://aeroridetest.blob.core.windows.net/legal/privacy-policy-2026-01.pdf';

  final UserService _service = UserService();

  bool _loading = true;
  String? _error;
  UserModel? _me;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await _service.getMyProfile();
      if (!mounted) return;
      setState(() {
        _me = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _openUpdateSheet(UserModel me) async {
    final updated = await showModalBottomSheet<UserModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdatePersonalInfoSheet(initial: me),
    );

    if (updated != null && mounted) {
      setState(() => _me = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  Future<void> _openLegalDoc(
      {required String title, required String url}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 34),
              const SizedBox(height: 8),
              Text(
                'Error loading profile\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final me = _me;
    if (me == null) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Load profile'),
        ),
      );
    }

    final displayName = me.fullName.isEmpty ? me.email : me.fullName;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ Unificado: Bienvenido + Account info + Update al final
          _InfoCard(
            title: 'Account info',
            children: [
              Text(
                'Welcome,\n$displayName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 14),
              _InfoRow(label: 'Email', value: me.email),
              _InfoRow(label: 'Phone', value: me.phoneNumber),
              _InfoRow(label: 'Country', value: me.country ?? '-'),
              _InfoRow(
                  label: 'Member since', value: _fmtDate(me.registrationDate)),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => _openUpdateSheet(me),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Color(0xFF0077FF)),
                      SizedBox(width: 8),
                      Text(
                        'Update personal info',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ Legal (igual que ya te gustó)
          _InfoCard(
            title: 'Legal',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Terms of Use'),
                subtitle: const Text('Accepted at registration'),
                trailing: TextButton(
                  onPressed: () => _openLegalDoc(
                    title: 'Terms of Use',
                    url: _termsUrl,
                  ),
                  child: const Text('View'),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Privacy Notice'),
                subtitle: const Text('Accepted at registration'),
                trailing: TextButton(
                  onPressed: () => _openLegalDoc(
                    title: 'Privacy Notice',
                    url: _privacyUrl,
                  ),
                  child: const Text('View'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ Renombrado
          _InfoCard(
            title: 'Other options',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                title: const Text(
                  'Delete account',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('This option is not available yet.'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Not available'),
                      content: const Text(
                        'Account deletion is not enabled for clients yet.\n\n'
                        'If you need help, please contact support.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
