class AircraftModel {
  final int id;
  final String patent;
  final String model;
  final double price;
  final int seats;
  final int maxWeight;
  final String state;
  final String image;
  final bool isActive;

  AircraftModel({
    required this.id,
    required this.patent,
    required this.model,
    required this.price,
    required this.seats,
    required this.maxWeight,
    required this.state,
    required this.image,
    required this.isActive,
  });

  /// 🔹 Convierte un JSON proveniente del backend a un objeto AircraftModel
  factory AircraftModel.fromJson(Map<String, dynamic> json) {
    return AircraftModel(
      id: json['id'] ?? 0,
      patent: json['patent'] ?? '',
      model: json['model'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      seats: json['seats'] ?? 0,
      maxWeight: json['maxWeight'] ?? 0,
      state: json['state'] ?? '',
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  /// 🔹 Convierte el objeto a JSON (por si luego lo necesitás en updates o creates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patent': patent,
      'model': model,
      'price': price,
      'seats': seats,
      'maxWeight': maxWeight,
      'state': state,
      'image': image,
      'isActive': isActive,
    };
  }
}
