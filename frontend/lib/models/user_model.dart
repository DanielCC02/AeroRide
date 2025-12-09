class UserModel {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;
  final bool isActive;
  final String fullName;
  final String? companyName;
  final String? registrationDate;
  final bool? termsOfUse;
  final bool? privacyNotice;

  /// País principal del usuario (ej: "Costa Rica", "México").
  final String? country;

  UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.isActive,
    required this.fullName,
    this.companyName,
    this.registrationDate,
    this.termsOfUse,
    this.privacyNotice,
    this.country,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? false,
      companyName: json['companyName'],
      fullName: '${json['name'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      registrationDate: json['registrationDate'],
      termsOfUse: json['termsOfUse'],
      privacyNotice: json['privacyNotice'],
      country: json['country'], // 👈 lo leemos si viene en la respuesta
    );
  }

  // Método toJson (por si lo necesitás)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'isActive': isActive,
      'fullName': fullName,
      'companyName': companyName,
      'registrationDate': registrationDate,
      'termsOfUse': termsOfUse,
      'privacyNotice': privacyNotice,
      'country': country, // 👈 opcional
    };
  }
}
