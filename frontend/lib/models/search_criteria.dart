// lib/models/search_criteria.dart
// Criterios de búsqueda usando el modelo de dominio (airport_model.dart).

import 'airport_model.dart' as domain;

/// Criterios seleccionados para buscar aeronaves (provienen del Home).
class SearchCriteria {
  final domain.Airport from;
  final domain.Airport to;
  final int passengers;
  final DateTime departure; // fecha+hora elegidas en el Home

  const SearchCriteria({
    required this.from,
    required this.to,
    required this.passengers,
    required this.departure,
  });

  SearchCriteria copyWith({
    domain.Airport? from,
    domain.Airport? to,
    int? passengers,
    DateTime? departure,
  }) {
    return SearchCriteria(
      from: from ?? this.from,
      to: to ?? this.to,
      passengers: passengers ?? this.passengers,
      departure: departure ?? this.departure,
    );
  }
}
