// lib/models/reservation.dart
import 'plane.dart';
import 'airport_model.dart' as domain;

class Reservation {
  final String id;
  final Plane plane;
  final domain.Airport from;
  final domain.Airport to;
  final DateTime date;
  final int passengers;
  final double estFlightTimeMin;
  final double totalWeightKg;
  final double priceUsd;
  final bool lapInfant;
  final bool dog;

  const Reservation({
    required this.id,
    required this.plane,
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
    required this.estFlightTimeMin,
    required this.totalWeightKg,
    required this.priceUsd,
    this.lapInfant = false,
    this.dog = false,
  });
}
