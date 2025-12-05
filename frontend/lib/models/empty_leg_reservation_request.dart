// lib/models/empty_leg_reservation_request.dart

import 'reservation_create_request.dart'; // por PassengerCreateRequest

class EmptyLegReservationRequest {
  final int
  userId; // por ahora lo mandamos, aunque idealmente lo saque el back del token
  final int emptyLegFlightId;
  final double price;
  final bool lapChild;
  final bool assistanceAnimal;
  final String notes;
  final List<PassengerCreateRequest> passengers;

  EmptyLegReservationRequest({
    required this.userId,
    required this.emptyLegFlightId,
    required this.price,
    required this.lapChild,
    required this.assistanceAnimal,
    required this.notes,
    required this.passengers,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'emptyLegFlightId': emptyLegFlightId,
    'price': price,
    'lapChild': lapChild,
    'assistanceAnimal': assistanceAnimal,
    'notes': notes,
    'passengers': passengers.map((p) => p.toJson()).toList(),
  };
}
