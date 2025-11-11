// lib/models/airport_model.dart
// Modelo actualizado para reflejar los nuevos campos del backend.

class Airport {
  final int id;
  final String name; // Nombre del aeropuerto
  final String codeIATA; // IATA (3 letras)
  final String codeOACI; // OACI (4 letras)
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final double tax;
  final String image;
  final bool isActive;
  final String? openingTime; // "08:00:00"
  final String? closingTime; // "18:00:00"
  final String timeZone;     // Ejemplo: "America/Costa_Rica"
  final int? maxAllowedWeight; // Peso máximo permitido (kg)

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
  });

  // =============================================================
  // 🧭 FACTORY: From JSON
  // =============================================================
  factory Airport.fromJson(Map<String, dynamic> json) {
    // Helpers reutilizables
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

    int? pickInt(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is String) return int.tryParse(v);
      }
      return null;
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

      // 🕒 Nuevos campos
      openingTime: pick<String>(['openingTime', 'OpeningTime'], def: ''),
      closingTime: pick<String>(['closingTime', 'ClosingTime'], def: ''),
      timeZone: pick<String>(['timeZone', 'TimeZone'], def: 'UTC'),
      maxAllowedWeight: pickInt(['maxAllowedWeight', 'MaxAllowedWeight']),
    );
  }

  // =============================================================
  // 🚀 TO JSON
  // =============================================================
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
      };

  /// 🧾 Texto corto: “Aeropuerto … - SJO”
  String get oneLine => '$name - $codeIATA';
}
