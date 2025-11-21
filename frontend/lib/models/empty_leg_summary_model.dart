// lib/models/empty_leg_summary_model.dart

class EmptyLegSummaryModel {
  final int id;
  final DateTime departureTime;

  // Aeropuerto origen
  final String fromName;
  final String fromCodeIata;

  // Aeropuerto destino
  final String toName;
  final String toCodeIata;

  // Aeronave
  final String aircraftModel;
  final String? aircraftImage;

  // Capacidad / peso
  final int seats;
  final double? maxWeightLb;

  // Precio final de la empty leg
  final double price;

  EmptyLegSummaryModel({
    required this.id,
    required this.departureTime,
    required this.fromName,
    required this.fromCodeIata,
    required this.toName,
    required this.toCodeIata,
    required this.aircraftModel,
    this.aircraftImage,
    required this.seats,
    this.maxWeightLb,
    required this.price,
  });

  factory EmptyLegSummaryModel.fromJson(Map<String, dynamic> json) {
    // 👇 Todos los campos se leen de forma defensiva.
    // Si algo viene null, ponemos vacío o 0 según convenga.
    final id = json['id'] as int;

    final depTimeRaw = json['departureTime'] as String?;
    final depTime = depTimeRaw != null
        ? DateTime.parse(depTimeRaw)
        : DateTime.now();

    final fromName = json['departureAirportName'] as String? ?? '';
    final fromCodeIata = json['departureIATA'] as String? ?? '';

    final toName = json['arrivalAirportName'] as String? ?? '';
    final toCodeIata = json['arrivalIATA'] as String? ?? '';

    final aircraftModel = json['aircraftModel'] as String? ?? '';
    final aircraftImage = json['aircraftImage'] as String?;

    final seatsDynamic = json['seats'];
    final seats = seatsDynamic is int
        ? seatsDynamic
        : (seatsDynamic is num ? seatsDynamic.toInt() : 0);

    final maxWeightDynamic = json['maxWeight'];
    final maxWeightLb = maxWeightDynamic is num
        ? maxWeightDynamic.toDouble()
        : null;

    final priceDynamic = json['finalPrice'];
    final price = priceDynamic is num ? priceDynamic.toDouble() : 0.0;

    return EmptyLegSummaryModel(
      id: id,
      departureTime: depTime,
      fromName: fromName,
      fromCodeIata: fromCodeIata,
      toName: toName,
      toCodeIata: toCodeIata,
      aircraftModel: aircraftModel,
      aircraftImage: aircraftImage,
      seats: seats,
      maxWeightLb: maxWeightLb,
      price: price,
    );
  }
}
