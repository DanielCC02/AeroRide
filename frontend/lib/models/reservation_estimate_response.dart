// lib/models/reservation_estimate_response.dart

class ReservationEstimateResponse {
  final int totalMinutes;
  final double minuteCost;
  final double baseCost;
  final double taxes;
  final double waitCost;
  final double overnightCost;
  final double totalPrice;
  final bool isInternational;

  const ReservationEstimateResponse({
    required this.totalMinutes,
    required this.minuteCost,
    required this.baseCost,
    required this.taxes,
    required this.waitCost,
    required this.overnightCost,
    required this.totalPrice,
    required this.isInternational,
  });

  /// Parser más tolerante a variaciones de nombres de propiedades
  /// (por si el backend cambia mínimamente algunos keys).
  factory ReservationEstimateResponse.fromJson(Map<String, dynamic> j) {
    double d(v) => v is num ? v.toDouble() : (double.tryParse('$v') ?? 0);
    int i(v) => v is num ? v.toInt() : (int.tryParse('$v') ?? 0);
    bool b(v) => v is bool ? v : ('$v'.toLowerCase() == 'true');

    T pick<T>(List<String> keys, T Function(dynamic) conv, T fallback) {
      for (final k in keys) {
        if (j.containsKey(k) && j[k] != null) return conv(j[k]);
      }
      return fallback;
    }

    return ReservationEstimateResponse(
      totalMinutes: pick(['totalMinutes', 'minutes'], i, 0),
      minuteCost: pick(['minuteCost'], d, 0),
      baseCost: pick(['baseCost', 'base'], d, 0),
      taxes: pick(['taxes', 'tax'], d, 0),
      waitCost: pick(['waitCost', 'waitingCost'], d, 0),
      overnightCost: pick(['overnightCost'], d, 0),
      totalPrice: pick(['totalPrice', 'total'], d, 0),
      isInternational: pick(['isInternational', 'international'], b, false),
    );
  }

  @override
  String toString() =>
      'Estimate{minutes:$totalMinutes, total:$totalPrice, intl:$isInternational}';
}
