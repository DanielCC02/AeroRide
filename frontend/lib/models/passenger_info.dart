/// Datos de un pasajero para la reserva.
/// - `fullName`, `birthDate`, `passport`
/// Usado por: [PassengersFormScreen] y [ReservationScreen].
class PassengerInfo {
  final String fullName;
  final DateTime birthDate;
  final String passport;

  PassengerInfo({
    required this.fullName,
    required this.birthDate,
    required this.passport,
  });

  @override
  String toString() {
    final mm = birthDate.month.toString().padLeft(2, '0');
    final dd = birthDate.day.toString().padLeft(2, '0');
    return '$fullName · $passport · ${birthDate.year}-$mm-$dd';
  }
}
