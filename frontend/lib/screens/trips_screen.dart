import 'package:flutter/material.dart';
import '../widgets/upcoming_trips_empty.dart';
import '../widgets/upcoming_trip_card.dart';
import '../models/mock_trips.dart';

/// TripsScreen
/// ---------------------------------------------------------------------------
/// Pantalla principal del módulo de “Trips”. Contiene dos pestañas:
///  - "Upcoming": lista de vuelos futuros (usa dummy data por ahora).
///  - "Past trips": placeholder hasta conectar con backend.
///
/// ARQUITECTURA / RESPONSABILIDADES:
/// - Controla las tabs vía TabController.
/// - Lee la fuente de datos (por ahora el mock `mockUpcomingTrips`).
/// - Decide si mostrar la lista de tarjetas o el estado vacío
///   (`UpcomingTripsEmpty`) cuando no hay elementos.
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
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final trip = trips[index];

        return UpcomingTripCard(
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

  @override
  Widget build(BuildContext context) {
    // NOTA: Este Scaffold tiene su propio AppBar y TabBar. Si en el futuro
    // la Home también maneja AppBar coordinado, considerar NestedScrollView.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        centerTitle: true,
        // TODO(theme): Mover colores a Theme/ColorScheme para M3 y dark mode.
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
          // Placeholder para “Past trips”.
          const Center(child: Text('Past trips will be shown here')),
        ],
      ),
    );
  }
}
