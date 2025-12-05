// lib/models/reservation_estimate_request.dart
import 'segment_dto.dart';

class ReservationEstimateRequest {
  final List<int> aircraftIds;
  final int totalPassengers;
  final List<SegmentDto> segments;

  ReservationEstimateRequest({
    required this.aircraftIds,
    required this.totalPassengers,
    required this.segments,
  });

  Map<String, dynamic> toJson() {
    return {
      'aircraftIds': aircraftIds,
      'totalPassengers': totalPassengers,
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }
}
