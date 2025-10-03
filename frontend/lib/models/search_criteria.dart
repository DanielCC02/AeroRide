import '../models/airport.dart';

/// Criterios seleccionados para buscar aeronaves (provienen del Home).
class SearchCriteria {
  final Airport from;
  final Airport to;
  final int passengers;
  final DateTime departure; // fecha+hora elegidas en el Home

  const SearchCriteria({
    required this.from,
    required this.to,
    required this.passengers,
    required this.departure,
  });

  SearchCriteria copyWith({
    Airport? from,
    Airport? to,
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
