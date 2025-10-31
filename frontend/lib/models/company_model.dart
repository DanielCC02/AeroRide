import 'package:frontend/models/aircraft_model.dart';
import 'package:frontend/models/user_model.dart';

class CompanyModel {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final double emptyLegDiscount;
  final bool isActive;
  final DateTime createdAt;

  // Estas listas son del modelo, pero el backend puede no enviarlas en el DTO
  final List<UserModel> users;
  final List<AircraftModel> aircrafts;

  CompanyModel({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.address,
    this.emptyLegDiscount = 0.5,
    this.isActive = true,
    required this.createdAt,
    this.users = const [],
    this.aircrafts = const [],
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final usersJson = (json['users'] as List?) ?? const [];
    final aircraftsJson = (json['aircrafts'] as List?) ?? const [];

    return CompanyModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      emptyLegDiscount: (json['emptyLegDiscount'] as num?)?.toDouble() ?? 0.5,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      users: usersJson.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList(),
      aircrafts: aircraftsJson.map((e) => AircraftModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'emptyLegDiscount': emptyLegDiscount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'users': users.map((e) => e.toJson()).toList(),
      'aircrafts': aircrafts.map((e) => e.toJson()).toList(),
    };
  }
}
