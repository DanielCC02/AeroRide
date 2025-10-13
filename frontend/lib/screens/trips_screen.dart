import 'package:flutter/material.dart';
import '../widgets/upcoming_trips_empty.dart';
import '../widgets/past_trips_empty.dart';
import '../widgets/trip_card.dart';
import '../models/mock_trips.dart';

/// TripsScreen
/// ---------------------------------------------------------------------------
/// Pantalla principal del módulo de “Trips”. Contiene dos pestañas:
///  - "Upcoming": lista de vuelos futuros (usa dummy data por ahora).
///  - "Past trips": muestra historial de vuelos (o vacío si no hay).
///
/// ARQUITECTURA / RESPONSABILIDADES:
/// - Controla las tabs vía TabController.
/// - Lee la fuente de datos (por ahora el mock `mockUpcomingTrips`).
/// - Decide si mostrar la lista de tarjetas o el estado vacío
///   (`UpcomingTripsEmpty`) cuando no hay elementos.
/// Por ahora consume datos mock (`mockUpcomingTrips` y `mockPastTrips`).
/// Cuando esté la API:
///  - Sustituir por provider/repositorio con estados: loading/empty/error/success.
///  - Mantener la UI de tarjetas (reutilizamos `UpcomingTripCard`).
///
/// FUTURO (INTEGRACIÓN BACKEND):
/// - Sustituir `mockUpcomingTrips` por un provider/repositorio que
///   consuma el endpoint real (capa data).
/// - Manejar estados: loading / empty / error / success.
/// - Extraer los colores fijos a Theme/ColorScheme para M3 y dark mode.
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Controlador de 2 pestañas: Upcoming y Past trips.
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Builder de la lista de “Upcoming”.
  /// - Lee trips dummy desde `mockUpcomingTrips`.
  /// - Muestra `UpcomingTripsEmpty` si no hay elementos.
  /// - Renderiza tarjetas `UpcomingTripCard` separadas por espaciado.
  Widget _buildUpcomingTab(BuildContext context) {
    // TODO(backend): Reemplazar por lectura desde provider/repositorio.
    final trips = mockUpcomingTrips;

    if (trips.isEmpty) {
      return const UpcomingTripsEmpty();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final trip = trips[index];

        return TripCard(
          trip: trip,
          // Acción temporal: muestra un SnackBar.
          // FUTURO: navegar a pantalla de detalles (pasando `trip.id`).
          onDetails: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Details coming soon')),
            );
          },
        );
      },
    );
  }

   /// Lista de "Past trips".
  /// - Usa el MISMO diseño de card para mantener consistencia.
  /// - Cambia únicamente la fuente de datos (mockPastTrips).
  Widget _buildPastTab(BuildContext context) {
    final trips = mockPastTrips; // TODO: reemplazar por provider

    if (trips.isEmpty) return const PastTripsEmpty();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final trip = trips[index];
        return TripCard(
          trip: trip,
          onDetails: () {
            // FUTURO: navegar a detalles del viaje realizado (recibo/bitácora)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Past trip details coming soon')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // NOTA: Colores fijos por ahora. Cuando migremos a M3,
    // mover a Theme/ColorScheme y habilitar dark mode.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past trips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTab(context),
          _buildPastTab(context),
        ],
      ),
    );
  }
}

