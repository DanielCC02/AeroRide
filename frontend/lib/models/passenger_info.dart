enum PassengerGender { masculino, femenino }

extension PassengerGenderX on PassengerGender {
  String get apiValue =>
      this == PassengerGender.femenino ? 'Femenino' : 'Masculino';

  static PassengerGender fromApi(String s) => s.toLowerCase().startsWith('f')
      ? PassengerGender.femenino
      : PassengerGender.masculino;
}

class PassengerInfo {
  String? name;
  String? middleName;
  String? lastName;
  String? passport;
  String? nationality;
  DateTime? dateOfBirth;
  PassengerGender gender;

  PassengerInfo({
    this.name,
    this.middleName,
    this.lastName,
    this.passport,
    this.nationality,
    this.dateOfBirth,
    this.gender = PassengerGender.masculino,
  });

  Map<String, dynamic> toApiJson() => {
    'name': name ?? '',
    'middleName': middleName ?? '',
    'lastName': lastName ?? '',
    'passport': passport ?? '',
    'nationality': nationality ?? '',
    'dateOfBirth': (dateOfBirth ?? DateTime(2000, 1, 1))
        .toUtc()
        .toIso8601String(),
    'gender': gender.apiValue,
  };

  @override
  String toString() => '${name ?? ''} ${lastName ?? ''} • ${passport ?? ''}';
}
