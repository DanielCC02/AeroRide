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
