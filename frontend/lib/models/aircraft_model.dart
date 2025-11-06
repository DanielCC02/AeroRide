class AircraftModel {
  final int id;
  final String patent;
  final String model;
  final double minuteCost;
  final int seats;
  final int emptyWeight;
  final int maxWeight;
  final double cruisingSpeed;
  final bool canFlyInternational;
  final String state;
  final String image;
  final bool isActive;

  // Relaciones
  final int baseAirportId;
  final int? currentAirportId;
  final int? companyId;

  // Nombres descriptivos (vienen del backend)
  final String companyName;
  final String baseAirportName;
  final String? currentAirportName;

  AircraftModel({
    required this.id,
    required this.patent,
    required this.model,
    required this.minuteCost,
    required this.seats,
    required this.emptyWeight,
    required this.maxWeight,
    required this.cruisingSpeed,
    required this.canFlyInternational,
    required this.state,
    required this.image,
    required this.isActive,
    required this.baseAirportId,
    this.currentAirportId,
    this.companyId,
    required this.companyName,
    required this.baseAirportName,
    this.currentAirportName,
  });

  /// 🔹 Convierte JSON del backend a objeto AircraftModel
  factory AircraftModel.fromJson(Map<String, dynamic> json) {
    return AircraftModel(
      id: json['id'] ?? 0,
      patent: json['patent'] ?? '',
      model: json['model'] ?? '',
      minuteCost: (json['minuteCost'] ?? 0).toDouble(),
      seats: json['seats'] ?? 0,
      emptyWeight: json['emptyWeight'] ?? 0,
      maxWeight: json['maxWeight'] ?? 0,
      cruisingSpeed: (json['cruisingSpeed'] ?? 0).toDouble(),
      canFlyInternational: json['canFlyInternational'] ?? false,
      state: json['state'] ?? '',
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? false,
      baseAirportId: json['baseAirportId'] ?? 0,
      currentAirportId: json['currentAirportId'],
      companyId: json['companyId'],
      companyName: json['companyName'] ?? '—',
      baseAirportName: json['baseAirportName'] ?? '—',
      currentAirportName: json['currentAirportName'],
    );
  }

  /// 🔹 Convierte el objeto a JSON (útil para POST o PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patent': patent,
      'model': model,
      'minuteCost': minuteCost,
      'seats': seats,
      'emptyWeight': emptyWeight,
      'maxWeight': maxWeight,
      'cruisingSpeed': cruisingSpeed,
      'canFlyInternational': canFlyInternational,
      'state': state,
      'image': image,
      'isActive': isActive,
      'baseAirportId': baseAirportId,
      'currentAirportId': currentAirportId,
      'companyId': companyId,
      'companyName': companyName,
      'baseAirportName': baseAirportName,
      'currentAirportName': currentAirportName,
    };
  }
}
