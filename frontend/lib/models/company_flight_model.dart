import 'package:flutter/foundation.dart';

/// Modelo que representa la respuesta de un vuelo desde el backend.
/// Mapea 1:1 con FlightResponseDto (ASP.NET Core).
class CompanyFlightModel {
  final int id;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double durationMinutes;
  final bool isEmptyLeg;
  final bool isInternational;
  final String status;

  // =====================
  // Aeropuertos
  // =====================
  final String? departureAirportName;
  final String? departureAirportIATA;
  final String? departureAirportOACI;

  final String? arrivalAirportName;
  final String? arrivalAirportIATA;
  final String? arrivalAirportOACI;

  // =====================
  // Aeronave / compañía
  // =====================
  final String? aircraftModel;
  final String? aircraftPatent;
  final String? companyName;
  final String? reservationCode;

  // =====================
  // Tripulación asignada
  // =====================
  final bool hasAssignedPilots;
  final int assignedPilotCount;

  const CompanyFlightModel({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.isEmptyLeg,
    required this.isInternational,
    required this.status,

    // Aeropuertos
    this.departureAirportName,
    this.departureAirportIATA,
    this.departureAirportOACI,
    this.arrivalAirportName,
    this.arrivalAirportIATA,
    this.arrivalAirportOACI,

    // Aeronave
    this.aircraftModel,
    this.aircraftPatent,
    this.companyName,
    this.reservationCode,

    // Crew
    required this.hasAssignedPilots,
    required this.assignedPilotCount,
  });

  /// Crea una instancia desde JSON (camelCase esperado desde ASP.NET Core).
  factory CompanyFlightModel.fromJson(Map<String, dynamic> json) {
    return CompanyFlightModel(
      id: json['id'] as int,
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      durationMinutes: (json['durationMinutes'] as num).toDouble(),
      isEmptyLeg: json['isEmptyLeg'] as bool,
      isInternational: json['isInternational'] as bool,
      status: json['status'] as String,

      // Aeropuertos
      departureAirportName: json['departureAirportName'],
      departureAirportIATA: json['departureAirportIATA'],
      departureAirportOACI: json['departureAirportOACI'],
      arrivalAirportName: json['arrivalAirportName'],
      arrivalAirportIATA: json['arrivalAirportIATA'],
      arrivalAirportOACI: json['arrivalAirportOACI'],

      // Aeronave / compañía
      aircraftModel: json['aircraftModel'],
      aircraftPatent: json['aircraftPatent'],
      companyName: json['companyName'],
      reservationCode: json['reservationCode'],

      // Crew
      hasAssignedPilots: json['hasAssignedPilots'] ?? false,
      assignedPilotCount: json['assignedPilotCount'] ?? 0,
    );
  }

  /// Serializa a JSON (útil si en algún momento debemos reenviar el objeto).
  Map<String, dynamic> toJson() => {
        'id': id,
        'departureTime': departureTime.toUtc().toIso8601String(),
        'arrivalTime': arrivalTime.toUtc().toIso8601String(),
        'durationMinutes': durationMinutes,
        'isEmptyLeg': isEmptyLeg,
        'isInternational': isInternational,
        'status': status,

        // Aeropuertos
        'departureAirportName': departureAirportName,
        'departureAirportIATA': departureAirportIATA,
        'departureAirportOACI': departureAirportOACI,
        'arrivalAirportName': arrivalAirportName,
        'arrivalAirportIATA': arrivalAirportIATA,
        'arrivalAirportOACI': arrivalAirportOACI,

        // Aeronave / compañía
        'aircraftModel': aircraftModel,
        'aircraftPatent': aircraftPatent,
        'companyName': companyName,
        'reservationCode': reservationCode,

        // Crew
        'hasAssignedPilots': hasAssignedPilots,
        'assignedPilotCount': assignedPilotCount,
      };

  /// Copia inmutable con cambios puntuales.
  CompanyFlightModel copyWith({
    int? id,
    DateTime? departureTime,
    DateTime? arrivalTime,
    double? durationMinutes,
    bool? isEmptyLeg,
    bool? isInternational,
    String? status,

    String? departureAirportName,
    String? departureAirportIATA,
    String? departureAirportOACI,

    String? arrivalAirportName,
    String? arrivalAirportIATA,
    String? arrivalAirportOACI,

    String? aircraftModel,
    String? aircraftPatent,
    String? companyName,
    String? reservationCode,

    bool? hasAssignedPilots,
    int? assignedPilotCount,
  }) {
    return CompanyFlightModel(
      id: id ?? this.id,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isEmptyLeg: isEmptyLeg ?? this.isEmptyLeg,
      isInternational: isInternational ?? this.isInternational,
      status: status ?? this.status,

      // Aeropuertos
      departureAirportName:
          departureAirportName ?? this.departureAirportName,
      departureAirportIATA:
          departureAirportIATA ?? this.departureAirportIATA,
      departureAirportOACI:
          departureAirportOACI ?? this.departureAirportOACI,
      arrivalAirportName: arrivalAirportName ?? this.arrivalAirportName,
      arrivalAirportIATA: arrivalAirportIATA ?? this.arrivalAirportIATA,
      arrivalAirportOACI: arrivalAirportOACI ?? this.arrivalAirportOACI,

      // Aeronave
      aircraftModel: aircraftModel ?? this.aircraftModel,
      aircraftPatent: aircraftPatent ?? this.aircraftPatent,
      companyName: companyName ?? this.companyName,
      reservationCode: reservationCode ?? this.reservationCode,

      // Crew
      hasAssignedPilots: hasAssignedPilots ?? this.hasAssignedPilots,
      assignedPilotCount:
          assignedPilotCount ?? this.assignedPilotCount,
    );
  }

  // =====================
  // Helpers útiles en UI
  // =====================

  DateTime get departureLocal => departureTime.toLocal();
  DateTime get arrivalLocal => arrivalTime.toLocal();

  Duration get duration => Duration(minutes: durationMinutes.round());

  static DateTime dayKey(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  @override
  String toString() =>
      'FlightModel(id: $id, departure=$departureTime, arrival=$arrivalTime, status=$status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyFlightModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Utilidad para parsear listas de vuelos.
@immutable
class FlightParser {
  const FlightParser._();

  static List<CompanyFlightModel> fromJsonList(List<dynamic> data) {
    return data
        .map((e) => CompanyFlightModel.fromJson(e))
        .toList();
  }
}
