// lib/models/airport_model.dart

class Airport {
  final int id;
  final String name;
  final String codeIATA;
  final String codeOACI;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final double tax;
  final String image;
  final bool isActive;
  final String? openingTime; 
  final String? closingTime; 
  final String timeZone;
  final int? maxAllowedWeight;
  final int departureMarginMinutes;
  final int arrivalMarginMinutes;

  const Airport({
    required this.id,
    required this.name,
    required this.codeIATA,
    required this.codeOACI,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.tax,
    required this.image,
    required this.isActive,
    this.openingTime,
    this.closingTime,
    required this.timeZone,
    this.maxAllowedWeight,
    this.departureMarginMinutes = 60,
    this.arrivalMarginMinutes = 30,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    T pick<T>(List<String> keys, {T? def}) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k] as T;
      }
      if (def != null) return def;
      throw StateError('Missing keys: $keys');
    }

    double pickNum(List<String> keys, {double def = 0}) {
      for (final k in keys) {
        final v = json[k];
        if (v is num) return v.toDouble();
        if (v is String) {
          final parsed = double.tryParse(v);
          if (parsed != null) return parsed;
        }
      }
      return def;
    }

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

    return Airport(
      id: pick<int>(['id', 'Id']),
      name: pick<String>(['name', 'Name']),
      codeIATA: pick<String>(['codeIATA', 'CodeIATA']),
      codeOACI: pick<String>(['codeOACI', 'CodeOACI']),
      city: pick<String>(['city', 'City']),
      country: pick<String>(['country', 'Country']),
      latitude: pickNum(['latitude', 'Latitude']),
      longitude: pickNum(['longitude', 'Longitude']),
      tax: pickNum(['tax', 'Tax']),
      image: pick<String>(['image', 'Image'], def: ''),
      isActive: pick<bool>(['isActive', 'IsActive'], def: true),
      openingTime: pick<String>(['openingTime', 'OpeningTime'], def: ''),
      closingTime: pick<String>(['closingTime', 'ClosingTime'], def: ''),
      timeZone: pick<String>(['timeZone', 'TimeZone'], def: 'UTC'),
      maxAllowedWeight: pickInt(['maxAllowedWeight', 'MaxAllowedWeight'], def: 5000),
      departureMarginMinutes:
          pickInt(['departureMarginMinutes', 'DepartureMarginMinutes'], def: 60),
      arrivalMarginMinutes:
          pickInt(['arrivalMarginMinutes', 'ArrivalMarginMinutes'], def: 30),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'codeIATA': codeIATA,
        'codeOACI': codeOACI,
        'city': city,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'tax': tax,
        'image': image,
        'isActive': isActive,
        'openingTime': openingTime,
        'closingTime': closingTime,
        'timeZone': timeZone,
        'maxAllowedWeight': maxAllowedWeight,
        'departureMarginMinutes': departureMarginMinutes,
        'arrivalMarginMinutes': arrivalMarginMinutes,
      };

  String get oneLine => '$name - $codeIATA';
}
