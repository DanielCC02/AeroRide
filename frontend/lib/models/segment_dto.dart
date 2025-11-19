// lib/models/segment_dto.dart

/// Representa un tramo de vuelo.
/// - En ESTIMATE: `arrivalTime` puede omitirse.
/// - En CREATE: `arrivalTime` debe enviarse.
///
/// Siempre serializamos tiempos en **UTC** (ISO 8601).
class SegmentDto {
  final int departureAirportId;
  final int arrivalAirportId;
  final DateTime departureTime; // UTC
  final DateTime? arrivalTime; // null en estimate, requerido en create

  SegmentDto({
    required this.departureAirportId,
    required this.arrivalAirportId,
    required this.departureTime,
    this.arrivalTime,
  }) : assert(
         departureAirportId > 0 && arrivalAirportId > 0,
         'Airport ids must be > 0',
       );

  /// toJson para estimate/create. En estimate **no** incluimos arrivalTime.
  Map<String, dynamic> toJson({bool includeArrival = true}) {
    final map = <String, dynamic>{
      'departureAirportId': departureAirportId,
      'arrivalAirportId': arrivalAirportId,
      'departureTime': departureTime.toUtc().toIso8601String(),
    };
    if (includeArrival && arrivalTime != null) {
      map['arrivalTime'] = arrivalTime!.toUtc().toIso8601String();
    }
    return map;
  }

  /// fromJson tolerante: acepta string/DateTime para los tiempos.
  factory SegmentDto.fromJson(Map<String, dynamic> j) {
    DateTime _asDtUtc(dynamic v) {
      if (v is DateTime) return v.toUtc();
      final parsed = DateTime.tryParse('$v');
      if (parsed != null) return parsed.toUtc();
      // fallback defensivo
      return DateTime.now().toUtc();
    }

    int _asInt(dynamic v) => v is num ? v.toInt() : (int.tryParse('$v') ?? 0);

    return SegmentDto(
      departureAirportId: _asInt(j['departureAirportId']),
      arrivalAirportId: _asInt(j['arrivalAirportId']),
      departureTime: _asDtUtc(j['departureTime']),
      arrivalTime: j.containsKey('arrivalTime') && j['arrivalTime'] != null
          ? _asDtUtc(j['arrivalTime'])
          : null,
    );
  }

  SegmentDto copyWith({
    int? departureAirportId,
    int? arrivalAirportId,
    DateTime? departureTime,
    DateTime? arrivalTime,
  }) {
    return SegmentDto(
      departureAirportId: departureAirportId ?? this.departureAirportId,
      arrivalAirportId: arrivalAirportId ?? this.arrivalAirportId,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }

  @override
  String toString() =>
      'Segment($departureAirportId->$arrivalAirportId, dep:${departureTime.toUtc().toIso8601String()}, '
      'arr:${arrivalTime?.toUtc().toIso8601String() ?? '-'})';
}
