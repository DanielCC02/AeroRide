// lib/models/search_criteria.dart
import 'airport_model.dart' as domain;

class SearchCriteria {
  final domain.Airport from;
  final domain.Airport to;
  final int passengers;
  final DateTime departure;
  final bool isRoundTrip;
  final DateTime? returnDateTime;

  const SearchCriteria({
    required this.from,
    required this.to,
    required this.passengers,
    required this.departure,
    this.isRoundTrip = false,
    this.returnDateTime,
  });

  SearchCriteria copyWith({
    domain.Airport? from,
    domain.Airport? to,
    int? passengers,
    DateTime? departure,
    bool? isRoundTrip,
    DateTime? returnDateTime,
  }) {
    return SearchCriteria(
      from: from ?? this.from,
      to: to ?? this.to,
      passengers: passengers ?? this.passengers,
      departure: departure ?? this.departure,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      returnDateTime: (isRoundTrip ?? this.isRoundTrip)
          ? (returnDateTime ?? this.returnDateTime)
          : null,
    );
  }
}
