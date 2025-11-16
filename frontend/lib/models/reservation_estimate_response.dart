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
    double _d(v) => v is num ? v.toDouble() : (double.tryParse('$v') ?? 0);
    int _i(v) => v is num ? v.toInt() : (int.tryParse('$v') ?? 0);
    bool _b(v) => v is bool ? v : ('$v'.toLowerCase() == 'true');

    T _pick<T>(List<String> keys, T Function(dynamic) conv, T fallback) {
      for (final k in keys) {
        if (j.containsKey(k) && j[k] != null) return conv(j[k]);
      }
      return fallback;
    }

    return ReservationEstimateResponse(
      totalMinutes: _pick(['totalMinutes', 'minutes'], _i, 0),
      minuteCost: _pick(['minuteCost'], _d, 0),
      baseCost: _pick(['baseCost', 'base'], _d, 0),
      taxes: _pick(['taxes', 'tax'], _d, 0),
      waitCost: _pick(['waitCost', 'waitingCost'], _d, 0),
      overnightCost: _pick(['overnightCost'], _d, 0),
      totalPrice: _pick(['totalPrice', 'total'], _d, 0),
      isInternational: _pick(['isInternational', 'international'], _b, false),
    );
  }

  @override
  String toString() =>
      'Estimate{minutes:$totalMinutes, total:$totalPrice, intl:$isInternational}';
}
