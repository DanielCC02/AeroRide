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

  // 💰 Nuevos campos opcionales del backend
  final double? domesticWaitHourCost;
  final double? internationalWaitHourCost;
  final double? domesticOvernightCost;
  final double? internationalOvernightCost;
  final double? airportTaxPerPassenger;
  final double? handlingPerPassenger;

  // 🔗 Relaciones
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
    this.domesticWaitHourCost,
    this.internationalWaitHourCost,
    this.domesticOvernightCost,
    this.internationalOvernightCost,
    this.airportTaxPerPassenger,
    this.handlingPerPassenger,
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

      // 💰 Campos de tarifas opcionales
      domesticWaitHourCost: (json['domesticWaitHourCost'] as num?)?.toDouble(),
      internationalWaitHourCost: (json['internationalWaitHourCost'] as num?)?.toDouble(),
      domesticOvernightCost: (json['domesticOvernightCost'] as num?)?.toDouble(),
      internationalOvernightCost: (json['internationalOvernightCost'] as num?)?.toDouble(),
      airportTaxPerPassenger: (json['airportTaxPerPassenger'] as num?)?.toDouble(),
      handlingPerPassenger: (json['handlingPerPassenger'] as num?)?.toDouble(),

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

      // 💰 Nuevos campos opcionales
      'domesticWaitHourCost': domesticWaitHourCost,
      'internationalWaitHourCost': internationalWaitHourCost,
      'domesticOvernightCost': domesticOvernightCost,
      'internationalOvernightCost': internationalOvernightCost,
      'airportTaxPerPassenger': airportTaxPerPassenger,
      'handlingPerPassenger': handlingPerPassenger,

      'users': users.map((e) => e.toJson()).toList(),
      'aircrafts': aircrafts.map((e) => e.toJson()).toList(),
    };
  }
}
