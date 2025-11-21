// lib/models/available_aircraft_model.dart
class AvailableAircraftModel {
  // Nuevos (opcionales) para soportar /api/Aircrafts/grouped
  final int? id;
  final String? state;
  final bool? canFlyInternational;
  final String baseCountry; // pedido para mostrar en UI
  final String? baseAirportName;

  // Existentes
  final int companyId;
  final String companyName;
  final String model; // mostrar EXACTO
  final String image;
  final int seats;
  final double? estimatedPrice;

  const AvailableAircraftModel({
    this.id,
    this.state,
    this.canFlyInternational,
    this.baseCountry = '',
    this.baseAirportName,
    required this.companyId,
    required this.companyName,
    required this.model,
    required this.image,
    required this.seats,
    this.estimatedPrice,
  });

  factory AvailableAircraftModel.fromJson(Map<String, dynamic> json) {
    int pickInt(List<String> keys, {int def = 0}) {
      for (final k in keys) {
        final v = json[k];
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is String) {
          final parsed = int.tryParse(v);
          if (parsed != null) return parsed;
        }
      }
      return def;
    }

    double? pickDouble(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v == null) continue;
        if (v is num) return v.toDouble();
        if (v is String) return double.tryParse(v);
      }
      return null;
    }

    bool? pickBool(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v == null) continue;
        if (v is bool) return v;
        if (v is String) {
          final s = v.toLowerCase();
          if (s == 'true' || s == '1') return true;
          if (s == 'false' || s == '0') return false;
        }
      }
      return null;
    }

    String pickStr(List<String> keys, {String def = ''}) {
      for (final k in keys) {
        final v = json[k];
        if (v is String && v.isNotEmpty) return v;
      }
      return def;
    }

    // Soporte para company anidado
    int companyId = pickInt(['companyId', 'CompanyId']);
    String companyName = pickStr(['companyName', 'CompanyName']);

    final companyObj = (json['company'] ?? json['Company']);
    if (companyObj is Map<String, dynamic>) {
      if (companyId == 0) {
        final v = companyObj['id'] ?? companyObj['Id'];
        if (v is int) companyId = v;
        if (v is num) companyId = v.toInt();
        if (v is String) companyId = int.tryParse(v) ?? 0;
      }
      if (companyName.isEmpty) {
        final v = companyObj['name'] ?? companyObj['Name'];
        if (v is String && v.isNotEmpty) companyName = v;
      }
    }

    return AvailableAircraftModel(
      id: pickInt(['id', 'Id'], def: 0),
      state: pickStr(['state', 'State']),
      canFlyInternational: pickBool([
        'canFlyInternational',
        'CanFlyInternational',
      ]),
      baseCountry: pickStr(['baseCountry', 'BaseCountry']),
      baseAirportName: pickStr(['baseAirportName', 'BaseAirportName']),
      companyId: companyId,
      companyName: companyName,
      model: pickStr(['model', 'Model', 'modelName', 'aircraftModel', 'name']),
      image: pickStr(['image', 'Image', 'thumbnail']),
      seats: pickInt(['seats', 'Seats', 'capacity', 'maxSeats']),
      estimatedPrice: pickDouble([
        'estimatedPrice',
        'EstimatedPrice',
        'price',
        'Price',
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (state != null) 'state': state,
    if (canFlyInternational != null) 'canFlyInternational': canFlyInternational,
    'baseCountry': baseCountry,
    if (baseAirportName != null) 'baseAirportName': baseAirportName,
    'companyId': companyId,
    'companyName': companyName,
    'model': model,
    'image': image,
    'seats': seats,
    if (estimatedPrice != null) 'estimatedPrice': estimatedPrice,
  };
}
