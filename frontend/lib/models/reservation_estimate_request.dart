// lib/models/reservation_estimate_request.dart
import 'segment_dto.dart';

class ReservationEstimateRequest {
  final int companyId;
  final String aircraftModel;
  final int totalPassengers;
  final List<SegmentDto> segments;

  ReservationEstimateRequest({
    required this.companyId,
    required this.aircraftModel,
    required this.totalPassengers,
    required this.segments,
  }) : assert(totalPassengers > 0, 'totalPassengers must be > 0');

  /// Importante:
  /// - `aircraftModel` se envía con .trim() para evitar fallos por espacios.
  /// - En ESTIMATE **no** se envía `arrivalTime`.
  Map<String, dynamic> toJson() => {
    'companyId': companyId,
    'aircraftModel': aircraftModel.trim(),
    'totalPassengers': totalPassengers,
    'segments': segments.map((s) => s.toJson(includeArrival: false)).toList(),
  };

  @override
  String toString() =>
      'EstimateReq(companyId:$companyId, model:${aircraftModel.trim()}, pax:$totalPassengers, segments:${segments.length})';
}
