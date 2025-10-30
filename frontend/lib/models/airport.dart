// lib/models/airport.dart
// Este archivo ahora provee un pequeño "view model" para la UI del buscador,
// evitando colisión de nombres con Airport del modelo de dominio.
// Si en alguna pantalla importabas este archivo, actualiza el import al airport_model.dart.
// Clase renombrada: AirportSuggestion.

import 'airport_model.dart';

class AirportSuggestion {
  final Airport airport;

  AirportSuggestion(this.airport);

  String get countryCity {
    final c = (airport.country).trim();
    final city = (airport.city).trim();
    if (c.isEmpty && city.isEmpty) return '';
    if (c.isEmpty) return city;
    if (city.isEmpty) return c;
    return '$c - $city';
  }

  String get airportAndIata => '${airport.name} - ${airport.codeIATA}';
}
