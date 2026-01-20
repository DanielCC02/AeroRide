class Trip {
  final int reservationId;
  final String reservationCode;

  final DateTime departureTime;

  final String originCity;
  final String originCode;

  final String destinationCity;
  final String destinationCode;

  final String imageUrl; // aeropuerto DESTINO
  final bool isUpcoming;

  Trip({
    required this.reservationId,
    required this.reservationCode,
    required this.departureTime,
    required this.originCity,
    required this.originCode,
    required this.destinationCity,
    required this.destinationCode,
    required this.imageUrl,
    required this.isUpcoming,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      reservationId: json['reservationId'],
      reservationCode: json['reservationCode'],
      departureTime: DateTime.parse(json['departureTime']),
      originCity: json['fromCity'],
      originCode: json['fromCode'],
      destinationCity: json['toCity'],
      destinationCode: json['toCode'],
      imageUrl: json['imageUrl'],
      isUpcoming: json['isUpcoming'],
    );
  }
}
