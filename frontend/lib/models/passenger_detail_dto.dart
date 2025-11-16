// lib/models/passenger_detail_dto.dart
class PassengerDetailDto {
  final int? id;
  final int reservationId;
  final String name;
  final String? middleName;
  final String lastName;
  final String passport;
  final DateTime dateOfBirth; // se enviará en UTC (solo fecha)
  final String? gender;
  final String nationality;

  PassengerDetailDto({
    this.id,
    required this.reservationId,
    required this.name,
    this.middleName,
    required this.lastName,
    required this.passport,
    required this.dateOfBirth,
    this.gender,
    required this.nationality,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'reservationId': reservationId,
    'name': name,
    'middleName': middleName,
    'lastName': lastName,
    'passport': passport,
    'dateOfBirth': DateTime(
      dateOfBirth.year,
      dateOfBirth.month,
      dateOfBirth.day,
    ).toUtc().toIso8601String(),
    'gender': gender,
    'nationality': nationality,
  };
}
