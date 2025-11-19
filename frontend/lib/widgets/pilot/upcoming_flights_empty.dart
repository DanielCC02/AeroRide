import 'package:flutter/material.dart';

class PilotUpcomingEmpty extends StatelessWidget {
  const PilotUpcomingEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight_takeoff,
                size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No upcoming flights",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don’t have any assigned flights yet.\nNew assignments will appear here.",
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
