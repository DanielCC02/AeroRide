import 'package:flutter/material.dart';
import '../models/trip.dart';

/// UpcomingTripCard
/// ---------------------------------------------------------------------------
/// Tarjeta visual para mostrar un viaje futuro en la lista de "Upcoming".
/// Se inspira en el mock adjunto: imagen de fondo, fecha arriba-izquierda,
/// origen → destino en tipografía grande y un botón “See Details” al frente.
///
/// PROPS:
/// - [trip]       : Entidad con datos del viaje (modelo provisional).
/// - [onDetails]  : Callback al presionar "See Details".
///
/// DISEÑO Y ACCESIBILIDAD:
/// - Usa `ClipRRect` con borderRadius para esquinas redondeadas.
/// - Aplica un `LinearGradient` sobre la imagen para mejorar contraste.
/// - Mantiene un `AspectRatio 16:9` para consistencia visual.
/// - TODO(theme): mover colores duros a Theme/ColorScheme (Material 3).
class UpcomingTripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onDetails;

  const UpcomingTripCard({
    super.key,
    required this.trip,
    this.onDetails,
  });

  // Helpers locales para formatear fecha en estilo corto inglés.
  // NOTA: Se mantienen “hardcodeados” porque el diseño del mock
  // usa abreviaturas (Mon, Tue, ... / aug, sep, ...). Si necesitas
  // i18n real, mover a `intl` + localizations.
  String _weekdayShort(int weekday) {
    // DateTime.weekday: 1=Mon..7=Sun
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
    final date = trip.departure;
    final dateLabel =
        '${_weekdayShort(date.weekday)} ${date.day} ${_monthShort(date.month)}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // --- Imagen de fondo (network) -----------------------------------
            // En producción, idealmente usarías un `CachedNetworkImage`.
            // Aquí se deja Image.network simple con fallbacks.
            Image.network(
              trip.imageUrl,
              fit: BoxFit.cover,
              // Placeholder simple mientras carga.
              loadingBuilder: (context, child, progress) =>
                  progress == null
                      ? child
                      : const ColoredBox(color: Color(0xFFEFEFEF)),
              // Fallback si falla la carga de imagen.
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: Color(0xFFCCCCCC)),
            ),

            // --- Gradiente para mejorar legibilidad del texto -----------------
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54, // arriba
                    Colors.transparent,
                    Colors.black54, // abajo
                  ],
                ),
              ),
            ),

            // --- Contenido textual y botón -----------------------------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta de fecha arriba-izquierda
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateLabel,
                      // TODO(i18n): mover a formateo con intl y locale de la app.
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Ruta grande (dos líneas como en el mock)
                  // Ej: "San José →" (línea 1) y "Nosara" (línea 2).
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip.origin} →',
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
                        trip.destination,
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

                  // Botón “See Details” alineado abajo-derecha
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      // TODO(theme): llevar estilos al tema global (M3).
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
