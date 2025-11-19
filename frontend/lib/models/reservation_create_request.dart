// lib/models/reservation_create_request.dart
import 'segment_dto.dart';

class PassengerCreateRequest {
  final String name;
  final String middleName;
  final String lastName;
  final String passport;
  final String nationality;
  final DateTime dateOfBirth;
  final String gender;

  PassengerCreateRequest({
    required this.name,
    required this.middleName,
    required this.lastName,
    required this.passport,
    required this.nationality,
    required this.dateOfBirth,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'middleName': middleName,
    'lastName': lastName,
    'passport': passport,
    'nationality': nationality,
    'dateOfBirth': dateOfBirth.toUtc().toIso8601String(),
    'gender': gender,
  };
}

class ReservationCreateRequest {
  final int companyId;
  final String aircraftModel;
  final int porcentPrice;
  final int totalPrice;
  final bool isRoundTrip;
  final bool assistanceAnimal;
  final bool lapChild;
  final String notes;
  final List<PassengerCreateRequest> passengers;
  final List<SegmentDto> segments;

  ReservationCreateRequest({
    required this.companyId,
    required this.aircraftModel,
    required this.porcentPrice,
    required this.totalPrice,
    required this.isRoundTrip,
    required this.assistanceAnimal,
    required this.lapChild,
    required this.notes,
    required this.passengers,
    required this.segments,
  });

  void validate() {
    if (companyId <= 0) {
      throw ArgumentError('companyId inválido.');
    }
    if (aircraftModel.trim().isEmpty) {
      throw ArgumentError('Debe indicar el modelo de aeronave.');
    }
    if (passengers.isEmpty) {
      throw ArgumentError('Debe agregar al menos 1 pasajero.');
    }
    if (segments.isEmpty) {
      throw ArgumentError('Debe definir al menos 1 segmento.');
    }
    for (final s in segments) {
      final dep = s.departureTime.toUtc();
      final arr = s.arrivalTime?.toUtc();
      if (arr == null) {
        throw ArgumentError('Falta arrivalTime en un segmento.');
      }
      if (!arr.isAfter(dep)) {
        throw ArgumentError(
          'arrivalTime debe ser estrictamente mayor a departureTime.',
        );
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'companyId': companyId,
    'aircraftModel': aircraftModel,
    'porcentPrice': porcentPrice,
    'totalPrice': totalPrice,
    'isRoundTrip': isRoundTrip,
    'assistanceAnimal': assistanceAnimal,
    'lapChild': lapChild,
    'notes': notes,
    'passengers': passengers.map((p) => p.toJson()).toList(),
    // ⬇️ En CREATE sí enviamos arrivalTime
    'segments': segments.map((s) => s.toJson(includeArrival: true)).toList(),
  };
}
