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
  final int? companyId;      
  final String? companyName;  

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
    this.companyId,
    this.companyName,
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
      companyId: json['companyId'],       
      companyName: json['companyName'],   
    );
  }

  /// 🔹 Convierte el objeto a JSON (útil para POST o PUT)
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
      'companyId': companyId,       
      'companyName': companyName,
    };
  }
}
