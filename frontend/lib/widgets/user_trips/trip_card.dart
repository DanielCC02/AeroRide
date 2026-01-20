import 'package:flutter/material.dart';
import '../../models/trip.dart';

/// TripCard
/// ---------------------------------------------------------------------------
/// Tarjeta visual para mostrar un viaje (Upcoming o Past).
/// El diseño es el mismo para ambos estados.
///
/// - Imagen de fondo: aeropuerto DESTINO (imageUrl desde backend)
/// - Fecha: departureTime
/// - Ruta: FromCity → ToCity
/// - Botón "See Details": se conectará más adelante
class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onDetails;

  const TripCard({
    super.key,
    required this.trip,
    this.onDetails,
  });

  // Helpers para formatear fecha corta (mock original)
  String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  String _monthShort(int month) {
    const names = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final date = trip.departureTime;
    final dateLabel =
        '${_weekdayShort(date.weekday)} ${date.day} ${_monthShort(date.month)}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // =========================================================
            // Imagen de fondo (aeropuerto DESTINO)
            // =========================================================
            Image.network(
              trip.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null
                      ? child
                      : const ColoredBox(color: Color(0xFFEFEFEF)),
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: Color(0xFFCCCCCC)),
            ),

            // =========================================================
            // Gradiente para legibilidad
            // =========================================================
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),

            // =========================================================
            // Contenido
            // =========================================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha (arriba-izquierda)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Ruta (From → To)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip.originCity} →',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        trip.destinationCity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Botón See Details (luego se conecta)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white70,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: onDetails,
                      child: const Text(
                        'See Details',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
