import 'package:flutter/material.dart';

class ContactOperatorsSheet extends StatelessWidget {
  const ContactOperatorsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Contact operator',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),

          // =========================
          // Cancel reservation
          // =========================
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text(
              'Cancel reservation',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              _showCancelWarning(context);
            },
          ),

          // =========================
          // Modify reservation
          // =========================
          ListTile(
            leading: const Icon(Icons.edit_calendar, color: Colors.orange),
            title: const Text(
              'Modify reservation',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              // 🔜 Future implementation
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // Alert: cancellation policy
  // ==========================================================
  void _showCancelWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancellation policy'),
        content: const Text(
          'If there are less than 24 hours before the flight, '
          'the reservation can be cancelled but no refunds will be issued.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
