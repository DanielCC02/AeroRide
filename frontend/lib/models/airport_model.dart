// lib/models/airport_model.dart
// Mantiene el nombre de clase Airport para no romper imports existentes.
// Estructura robusta para mapear respuestas camelCase o PascalCase.

class Airport {
  final int id;
  final String name; // Nombre del aeropuerto
  final String codeIATA; // IATA (3 letras)
  final String codeOACI; // OACI (4 letras) - opcional en API
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final double tax;
  final String image;
  final bool isActive;

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
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    // Helpers para llaves alternativas según el backend
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

    return Airport(
      id: pick<int>(['id', 'Id']),
      name: pick<String>(['name', 'Name']),
      codeIATA: pick<String>(['codeIATA', 'CodeIATA', 'iata', 'IATA']),
      codeOACI: pick<String>(['codeOACI', 'CodeOACI', 'oaci', 'OACI'], def: ''),
      city: pick<String>(['city', 'City'], def: ''),
      country: pick<String>(['country', 'Country'], def: ''),
      latitude: pickNum(['latitude', 'Latitude']),
      longitude: pickNum(['longitude', 'Longitude']),
      tax: pickNum(['tax', 'Tax']),
      image: pick<String>(['image', 'Image'], def: ''),
      isActive: pick<bool>(['isActive', 'IsActive'], def: true),
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
  };

  /// Texto de una línea útil para inputs: "Aeropuerto … - SJO"
  String get oneLine => '$name - $codeIATA';
}
