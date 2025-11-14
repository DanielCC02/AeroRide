class FlightAssignedPilotModel {
  final int pilotId;
  final String pilotName;
  final String pilotLastName;
  final String crewRole; 

  FlightAssignedPilotModel({
    required this.pilotId,
    required this.pilotName,
    required this.pilotLastName,
    required this.crewRole,
  });

  factory FlightAssignedPilotModel.fromJson(Map<String, dynamic> json) {
    return FlightAssignedPilotModel(
      pilotId: json['pilotId'] as int,
      pilotName: json['pilotName'] as String,
      pilotLastName: json['pilotLastName'] as String,
      crewRole: json['crewRole'] as String,
    );
  }

  String get fullName => '$pilotName $pilotLastName';
}
