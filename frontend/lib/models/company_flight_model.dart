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
  // Relacionados (opcionales)
  // =====================
  final String? departureAirportName;
  final String? arrivalAirportName;
  final String? aircraftModel;
  final String? aircraftPatent;
  final String? companyName;
  final String? reservationCode;

  const CompanyFlightModel({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.isEmptyLeg,
    required this.isInternational,
    required this.status,
    this.departureAirportName,
    this.arrivalAirportName,
    this.aircraftModel,
    this.aircraftPatent,
    this.companyName,
    this.reservationCode,
  });

  /// Crea una instancia desde JSON (camelCase esperado desde ASP.NET Core).
  factory CompanyFlightModel.fromJson(Map<String, dynamic> json) {
    return CompanyFlightModel(
      id: json['id'] as int,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      durationMinutes: (json['durationMinutes'] as num).toDouble(),
      isEmptyLeg: json['isEmptyLeg'] as bool,
      isInternational: json['isInternational'] as bool,
      status: json['status'] as String,
      departureAirportName: json['departureAirportName'] as String?,
      arrivalAirportName: json['arrivalAirportName'] as String?,
      aircraftModel: json['aircraftModel'] as String?,
      aircraftPatent: json['aircraftPatent'] as String?,
      companyName: json['companyName'] as String?,
      reservationCode: json['reservationCode'] as String?,
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
        'departureAirportName': departureAirportName,
        'arrivalAirportName': arrivalAirportName,
        'aircraftModel': aircraftModel,
        'aircraftPatent': aircraftPatent,
        'companyName': companyName,
        'reservationCode': reservationCode,
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
    String? arrivalAirportName,
    String? aircraftModel,
    String? aircraftPatent,
    String? companyName,
    String? reservationCode,
  }) {
    return CompanyFlightModel(
      id: id ?? this.id,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isEmptyLeg: isEmptyLeg ?? this.isEmptyLeg,
      isInternational: isInternational ?? this.isInternational,
      status: status ?? this.status,
      departureAirportName: departureAirportName ?? this.departureAirportName,
      arrivalAirportName: arrivalAirportName ?? this.arrivalAirportName,
      aircraftModel: aircraftModel ?? this.aircraftModel,
      aircraftPatent: aircraftPatent ?? this.aircraftPatent,
      companyName: companyName ?? this.companyName,
      reservationCode: reservationCode ?? this.reservationCode,
    );
  }

  // =====================
  // Helpers útiles en UI
  // =====================

  /// Versión local de las fechas (si el backend envía en UTC con 'Z').
  DateTime get departureLocal => departureTime.toLocal();
  DateTime get arrivalLocal => arrivalTime.toLocal();

  /// Duración como objeto Duration (a partir de los minutos).
  Duration get duration => Duration(minutes: durationMinutes.round());

  /// Normaliza una fecha al día (YYYY-MM-DD) para marcar eventos en el calendario.
  static DateTime dayKey(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  String toString() =>
      'FlightModel(id: $id, ${departureTime.toIso8601String()} → ${arrivalTime.toIso8601String()}, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyFlightModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Utilidad para parsear listas de vuelos.
@immutable
class FlightParser {
  const FlightParser._();

  static List<CompanyFlightModel> fromJsonList(List<dynamic> data) {
    return data
        .map((e) => CompanyFlightModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
