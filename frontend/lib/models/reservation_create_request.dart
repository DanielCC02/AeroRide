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

  /// REQUIRED BY BACKEND — list of real aircraft available
  final List<int> aircraftIds;

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
    required this.aircraftIds,
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
      throw ArgumentError('Invalid companyId.');
    }
    if (aircraftModel.trim().isEmpty) {
      throw ArgumentError('Aircraft model is required.');
    }
    if (aircraftIds.isEmpty) {
      throw ArgumentError('aircraftIds cannot be empty.');
    }
    if (passengers.isEmpty) {
      throw ArgumentError('At least one passenger is required.');
    }
    if (segments.isEmpty) {
      throw ArgumentError('At least one segment is required.');
    }
    for (final s in segments) {
      final dep = s.departureTime.toUtc();
      final arr = s.arrivalTime?.toUtc();
      if (arr == null) {
        throw ArgumentError('Missing arrivalTime in a segment.');
      }
      if (!arr.isAfter(dep)) {
        throw ArgumentError(
          'arrivalTime must be strictly after departureTime.',
        );
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'aircraftModel': aircraftModel,
      'aircraftIds': aircraftIds,
      'porcentPrice': porcentPrice,
      'totalPrice': totalPrice,
      'isRoundTrip': isRoundTrip,
      'assistanceAnimal': assistanceAnimal,
      'lapChild': lapChild,
      'notes': notes,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'segments': segments.map((s) => s.toJson(includeArrival: true)).toList(),
    };
  }
}
