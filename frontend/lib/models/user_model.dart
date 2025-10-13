class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final bool isActive;
  final String? name;
  final String? lastName;
  final String? registrationDate;
  final bool? termsOfUse;
  final bool? privacyNotice;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.isActive,
    this.name,
    this.lastName,
    this.registrationDate,
    this.termsOfUse,
    this.privacyNotice,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '${json['name'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? false,
      name: json['name'],
      lastName: json['lastName'],
      registrationDate: json['registrationDate'],
      termsOfUse: json['termsOfUse'],
      privacyNotice: json['privacyNotice'],
    );
  }
}
