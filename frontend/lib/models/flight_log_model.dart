/// Modelo que representa la bitácora de vuelo (PDF) devuelta por el backend.
/// Mapea 1:1 con FlightLogResponseDto.
class FlightLogModel {
  final int id;
  final int flightId;
  final int pilotUserId;
  final String pilotName;
  final String pilotLastName;
  final String pdfUrl;
  final DateTime createdAt;

  const FlightLogModel({
    required this.id,
    required this.flightId,
    required this.pilotUserId,
    required this.pilotName,
    required this.pilotLastName,
    required this.pdfUrl,
    required this.createdAt,
  });

  factory FlightLogModel.fromJson(Map<String, dynamic> json) {
    return FlightLogModel(
      id: json['id'] as int,
      flightId: json['flightId'] as int,
      pilotUserId: json['pilotUserId'] as int,
      pilotName: json['pilotName'] as String,
      pilotLastName: json['pilotLastName'] as String,
      pdfUrl: json['pdfUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'flightId': flightId,
        'pilotUserId': pilotUserId,
        'pilotName': pilotName,
        'pilotLastName': pilotLastName,
        'pdfUrl': pdfUrl,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  @override
  String toString() =>
      'FlightLogModel(id: $id, flightId: $flightId, pilot: $pilotName $pilotLastName)';
}
