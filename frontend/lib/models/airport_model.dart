// lib/models/airport_model.dart
class Airport {
  final int id;
  final String name;
  final String codeIATA;
  final String city;
  final String country;
  final double latitude;   // <- requerido
  final double longitude;  // <- requerido
  final double tax;
  final String image;
  final bool isActive;

  Airport({
    required this.id,
    required this.name,
    required this.codeIATA,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.tax,
    required this.image,
    required this.isActive,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    // System.Text.Json suele devolver camelCase (id, name, codeIATA, latitude...)
    final numLat = json['latitude'] as num;   // decimal -> num
    final numLng = json['longitude'] as num;
    final numTax = (json['tax'] as num?) ?? 0;

    return Airport(
      id: json['id'] as int,
      name: json['name'] as String,
      codeIATA: json['codeIATA'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      latitude: numLat.toDouble(),
      longitude: numLng.toDouble(),
      tax: numTax.toDouble(),
      image: json['image'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'codeIATA': codeIATA,
        'city': city,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'tax': tax,
        'image': image,
        'isActive': isActive,
      };
}
