class Airport {
  final String codeIata;
  final String name;
  final String country;
  final String codeOaci;
  final String image; // <- nuevo

  Airport({
    required this.codeIata,
    required this.name,
    required this.country,
    this.codeOaci = '',
    required this.image,
  });
}
