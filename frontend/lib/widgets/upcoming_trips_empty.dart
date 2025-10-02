import 'package:flutter/material.dart';
import '../screens/homepage_screen.dart'; // Importar pantalla de Home

/// Widget para mostrar el estado "sin vuelos próximos"
/// en la pestaña de Upcoming.
class UpcomingTripsEmpty extends StatelessWidget {
  const UpcomingTripsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight, // TEMP: se puede cambiar a un asset de avión
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              "You don't have any upcoming flights,\n"
              "book a flight to see the details here",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                // Redirigir al Home reemplazando la pantalla actual
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePageScreen(),
                  ),
                );
              },
              child: const Text("Book a flight"),
            ),
          ],
        ),
      ),
    );
  }
}