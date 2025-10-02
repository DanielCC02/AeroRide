class Trip {
  final String id;
  final DateTime departure;
  final String origin;   // Ej: "San José"
  final String originCode; // Ej: "SYQ"
  final String destination; // Ej: "Nosara"
  final String destinationCode; // Ej: "NOB"
  final String imageUrl; // Fondo de la tarjeta

  const Trip({
    required this.id,
    required this.departure,
    required this.origin,
    required this.originCode,
    required this.destination,
    required this.destinationCode,
    required this.imageUrl,
  });
}
