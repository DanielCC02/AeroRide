import 'package:flutter/material.dart';

import '../screens/welcome_screen.dart';
import '../screens/airports_screen.dart';
import '../screens/plane_list_screen.dart';
import '../screens/reservation_detail_screen.dart';
import '../screens/empty_legs_list_screen.dart';
import '../screens/empty_leg_detail_screen.dart';
import '../screens/map_screen.dart';
import '../screens/trips_screen.dart';
import '../screens/pilots_upcoming_screen.dart';
import '../screens/pilots_past_screen.dart';
import '../screens/logbook_entry_screen.dart';

import '../models/search_criteria.dart';
import '../models/reservation.dart';

class AppRoute {
  static const welcome = '/';
  static const airports = '/airports';
  static const planes = '/planes';
  static const reservationDetail = '/reservation-detail';
  static const emptyLegs = '/empty-legs';
  static const emptyLegDetail = '/empty-leg-detail';
  static const map = '/map';
  static const trips = '/trips';
  static const pilotsUpcoming = '/pilots-upcoming';
  static const pilotsPast = '/pilots-past';
  static const logbook = '/logbook';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoute.welcome:
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());

    case AppRoute.airports:
      return MaterialPageRoute(builder: (_) => const AirportsScreen());

    case AppRoute.planes:
      {
        // 👇 AHORA EXIGE SearchCriteria como argumento
        final criteria = settings.arguments as SearchCriteria;
        return MaterialPageRoute(
          builder: (_) => PlaneListScreen(criteria: criteria),
          settings: settings,
        );
      }

    case AppRoute.reservationDetail:
      {
        final reservation = settings.arguments as Reservation?;
        return MaterialPageRoute(
          builder: (_) => ReservationDetailScreen(reservation: reservation),
          settings: settings,
        );
      }

    case AppRoute.emptyLegs:
      return MaterialPageRoute(builder: (_) => const EmptyLegsListScreen());
    case AppRoute.emptyLegDetail:
      return MaterialPageRoute(builder: (_) => const EmptyLegDetailScreen());
    case AppRoute.map:
      return MaterialPageRoute(builder: (_) => const MapScreen());
    case AppRoute.trips:
      return MaterialPageRoute(builder: (_) => const TripsScreen());
    case AppRoute.pilotsUpcoming:
      return MaterialPageRoute(builder: (_) => const PilotsUpcomingScreen());
    case AppRoute.pilotsPast:
      return MaterialPageRoute(builder: (_) => const PilotsPastScreen());
    case AppRoute.logbook:
      return MaterialPageRoute(builder: (_) => const LogbookEntryScreen());
    default:
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());
  }
}
