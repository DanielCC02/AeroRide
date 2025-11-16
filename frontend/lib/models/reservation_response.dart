// lib/models/reservation_response.dart
class PassengerRes {
  final int id;
  final String name;
  final String middleName;
  final String lastName;
  final String passport;
  final String nationality;
  final DateTime dateOfBirth;
  final String gender;
  final int age;

  PassengerRes({
    required this.id,
    required this.name,
    this.middleName = '',
    required this.lastName,
    this.passport = '',
    this.nationality = '',
    required this.dateOfBirth,
    required this.gender,
    required this.age,
  });

  factory PassengerRes.fromJson(Map<String, dynamic> j) => PassengerRes(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    middleName: j['middleName'] as String? ?? '',
    lastName: j['lastName'] as String? ?? '',
    passport: j['passport'] as String? ?? '',
    nationality: j['nationality'] as String? ?? '',
    dateOfBirth: DateTime.parse(j['dateOfBirth'] as String).toUtc(),
    gender: j['gender'] as String? ?? '',
    age: (j['age'] as num?)?.toInt() ?? 0,
  );
}

class FlightRes {
  final int id;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int durationMinutes;
  final bool isEmptyLeg;
  final bool isInternational;
  final String status;
  final String departureAirportName;
  final String arrivalAirportName;
  final String aircraftModel;
  final String companyName;

  FlightRes({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.isEmptyLeg,
    required this.isInternational,
    required this.status,
    required this.departureAirportName,
    required this.arrivalAirportName,
    required this.aircraftModel,
    required this.companyName,
  });

  factory FlightRes.fromJson(Map<String, dynamic> j) => FlightRes(
    id: (j['id'] as num).toInt(),
    departureTime: DateTime.parse(j['departureTime'] as String).toUtc(),
    arrivalTime: DateTime.parse(j['arrivalTime'] as String).toUtc(),
    durationMinutes: (j['durationMinutes'] as num?)?.toInt() ?? 0,
    isEmptyLeg: j['isEmptyLeg'] as bool? ?? false,
    isInternational: j['isInternational'] as bool? ?? false,
    status: j['status'] as String? ?? '',
    departureAirportName: j['departureAirportName'] as String? ?? '',
    arrivalAirportName: j['arrivalAirportName'] as String? ?? '',
    aircraftModel: j['aircraftModel'] as String? ?? '',
    companyName: j['companyName'] as String? ?? '',
  );
}

class ReservationResponse {
  final int id;
  final String reservationCode;
  final int userId;
  final String companyName;
  final int porcentPrice;
  final num totalPrice;
  final bool isRoundTrip;
  final bool lapChild;
  final bool assistanceAnimal;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PassengerRes> passengers;
  final List<FlightRes> flights;

  ReservationResponse({
    required this.id,
    required this.reservationCode,
    required this.userId,
    required this.companyName,
    required this.porcentPrice,
    required this.totalPrice,
    required this.isRoundTrip,
    required this.lapChild,
    required this.assistanceAnimal,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.passengers,
    required this.flights,
  });

  factory ReservationResponse.fromJson(Map<String, dynamic> j) =>
      ReservationResponse(
        id: (j['id'] as num).toInt(),
        reservationCode: j['reservationCode'] as String? ?? '',
        userId: (j['userId'] as num?)?.toInt() ?? 0,
        companyName: j['companyName'] as String? ?? '',
        porcentPrice: (j['porcentPrice'] as num?)?.toInt() ?? 0,
        totalPrice: (j['totalPrice'] as num?) ?? 0,
        isRoundTrip: j['isRoundTrip'] as bool? ?? false,
        lapChild: j['lapChild'] as bool? ?? false,
        assistanceAnimal: j['assistanceAnimal'] as bool? ?? false,
        status: j['status'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String).toUtc(),
        updatedAt: DateTime.parse(j['updatedAt'] as String).toUtc(),
        passengers: (j['passengers'] as List? ?? const [])
            .map((x) => PassengerRes.fromJson(x as Map<String, dynamic>))
            .toList(),
        flights: (j['flights'] as List? ?? const [])
            .map((x) => FlightRes.fromJson(x as Map<String, dynamic>))
            .toList(),
      );
}
