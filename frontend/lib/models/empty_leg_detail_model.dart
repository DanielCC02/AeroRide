// lib/models/empty_leg_detail_model.dart

class EmptyLegDetailModel {
  final int id;

  final String aircraftModel;
  final String aircraftPatent;
  final String? aircraftImage;

  final int seats;
  final double? maxWeight;
  final double minuteCost;
  final bool canFlyInternational;
  final double finalPrice;

  final DateTime departureTime;
  final DateTime arrivalTime;
  final double durationMinutes;
  final String eft;

  final String departureIata;
  final String departureOaci;
  final String departureAirportName;
  final String departureCity;
  final String departureCountry;
  final String? departureAirportImage;

  final String arrivalIata;
  final String arrivalOaci;
  final String arrivalAirportName;
  final String arrivalCity;
  final String arrivalCountry;
  final String? arrivalAirportImage;

  final String companyName;
  final int companyId;
  final int maxPassengerCount;

  EmptyLegDetailModel({
    required this.id,
    required this.aircraftModel,
    required this.aircraftPatent,
    required this.aircraftImage,
    required this.seats,
    required this.maxWeight,
    required this.minuteCost,
    required this.canFlyInternational,
    required this.finalPrice,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.eft,
    required this.departureIata,
    required this.departureOaci,
    required this.departureAirportName,
    required this.departureCity,
    required this.departureCountry,
    required this.departureAirportImage,
    required this.arrivalIata,
    required this.arrivalOaci,
    required this.arrivalAirportName,
    required this.arrivalCity,
    required this.arrivalCountry,
    required this.arrivalAirportImage,
    required this.companyName,
    required this.companyId,
    required this.maxPassengerCount,
  });

  factory EmptyLegDetailModel.fromJson(Map<String, dynamic> json) {
    String? stringOrNull(String key) {
      final value = json[key];
      if (value == null) return null;
      return value.toString();
    }

    return EmptyLegDetailModel(
      id: (json['id'] as num).toInt(),
      aircraftModel: stringOrNull('aircraftModel') ?? '',
      aircraftPatent: stringOrNull('aircraftPatent') ?? '',
      aircraftImage: stringOrNull('aircraftImage'),
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      maxWeight: (json['maxWeight'] as num?)?.toDouble(),
      minuteCost: (json['minuteCost'] as num?)?.toDouble() ?? 0,
      canFlyInternational: json['canFlyInternational'] as bool? ?? false,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toDouble() ?? 0,
      eft: stringOrNull('eft') ?? '',
      departureIata: stringOrNull('departureIATA') ?? '',
      departureOaci: stringOrNull('departureOACI') ?? '',
      departureAirportName: stringOrNull('departureAirportName') ?? '',
      departureCity: stringOrNull('departureCity') ?? '',
      departureCountry: stringOrNull('departureCountry') ?? '',
      departureAirportImage: stringOrNull('departureAirportImage'),
      arrivalIata: stringOrNull('arrivalIATA') ?? '',
      arrivalOaci: stringOrNull('arrivalOACI') ?? '',
      arrivalAirportName: stringOrNull('arrivalAirportName') ?? '',
      arrivalCity: stringOrNull('arrivalCity') ?? '',
      arrivalCountry: stringOrNull('arrivalCountry') ?? '',
      arrivalAirportImage: stringOrNull('arrivalAirportImage'),
      companyName: stringOrNull('companyName') ?? '',
      companyId: (json['companyId'] as num?)?.toInt() ?? 0,
      maxPassengerCount: (json['maxPassengerCount'] as num?)?.toInt() ?? 0,
    );
  }
}
