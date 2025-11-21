// lib/models/reservation_estimate_response.dart
class ReservationEstimateResponse {
  final int? aircraftId;
  final double totalMinutes;
  final double minuteCost;
  final double baseCost;
  final double taxes;
  final double waitCost;
  final double overnightCost;
  final double totalPrice;
  final bool isInternational;

  ReservationEstimateResponse({
    this.aircraftId,
    required this.totalMinutes,
    required this.minuteCost,
    required this.baseCost,
    required this.taxes,
    required this.waitCost,
    required this.overnightCost,
    required this.totalPrice,
    required this.isInternational,
  });

  factory ReservationEstimateResponse.fromJson(Map<String, dynamic> json) {
    double d(Object? v) => (v is num) ? v.toDouble() : 0;

    return ReservationEstimateResponse(
      aircraftId: json['aircraftId'] as int?,
      totalMinutes: d(json['totalMinutes']),
      minuteCost: d(json['minuteCost']),
      baseCost: d(json['baseCost']),
      taxes: d(json['taxes']),
      waitCost: d(json['waitCost']),
      overnightCost: d(json['overnightCost']),
      totalPrice: d(json['totalPrice']),
      isInternational: json['isInternational'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aircraftId': aircraftId,
      'totalMinutes': totalMinutes,
      'minuteCost': minuteCost,
      'baseCost': baseCost,
      'taxes': taxes,
      'waitCost': waitCost,
      'overnightCost': overnightCost,
      'totalPrice': totalPrice,
      'isInternational': isInternational,
    };
  }
}
