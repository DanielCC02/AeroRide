import 'package:flutter/material.dart';
import '../screens/homepage_screen.dart';

/// PastTripsEmpty
/// ---------------------------------------------------------------------------
/// Estado vacío para la pestaña "Past trips".
/// - MISMO diseño visual que `UpcomingTripsEmpty`.
/// - ÚNICA diferencia: el mensaje mostrado.
/// - CTA "Book a flight" mantiene la navegación al Home.
/// 
/// NOTA: Igual que el widget de Upcoming, este widget navega con
/// `Navigator.pushReplacement` a la Home. Cuando centralicemos el enrutador,
/// convendrá que este botón solicite al contenedor cambiar al tab "Book".
class PastTripsEmpty extends StatelessWidget {
  const PastTripsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight, // se puede reemplazar por un asset de avión
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              // Copy solicitado para Past trips
              'You have not completed any trips yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
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
              child: const Text('Book a flight'),
            ),
          ],
        ),
      ),
    );
  }
}
