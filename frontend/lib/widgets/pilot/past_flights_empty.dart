import 'package:flutter/material.dart';

class PilotPastEmpty extends StatelessWidget {
  const PilotPastEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history,
                size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No past flights",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Completed flights will appear here once you finish and log them.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
