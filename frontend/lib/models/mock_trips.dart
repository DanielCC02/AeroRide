import 'trip.dart';

/// Dummy data para Upcoming
final mockUpcomingTrips = [
  Trip(
    id: 't1',
    departure: DateTime(2025, 8, 16, 8, 30),
    origin: 'San José',
    originCode: 'SYQ',
    destination: 'Nosara',
    destinationCode: 'NOB',
    imageUrl: 'https://images.unsplash.com/photo-1502082553048-f009c37129b9',
  ),
  Trip(
    id: 't2',
    departure: DateTime(2025, 8, 19, 9, 45),
    origin: 'San José',
    originCode: 'SYQ',
    destination: 'Tamarindo',
    destinationCode: 'TNO',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
  ),
];

/// Historial (trips ya completados). Reutiliza el mismo modelo y card.
/// En producción, la API debería diferenciar por estatus/fecha < ahora.
final mockPastTrips = [
  Trip(
    id: 'p1',
    departure: DateTime(2025, 5, 12, 7, 10),
    origin: 'Nosara',
    originCode: 'NOB',
    destination: 'San José',
    destinationCode: 'SYQ',
    imageUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
  ),
  Trip(
    id: 'p2',
    departure: DateTime(2025, 6, 3, 15, 20),
    origin: 'Tamarindo',
    originCode: 'TNO',
    destination: 'San José',
    destinationCode: 'SYQ',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
  ),
];