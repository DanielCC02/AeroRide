import 'package:flutter/material.dart';
import 'package:frontend/screens/trip_details_screen.dart';

import '../models/trip.dart';
import '../services/trip_service.dart';

// Estos widgets los haremos después
import '../widgets/user_trips/upcoming_trips_empty.dart';
import '../widgets/user_trips/past_trips_empty.dart';
import '../widgets/user_trips/trip_card.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TripService _service = TripService();

  List<Trip> _upcoming = [];
  List<Trip> _past = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================================
  // Cargar trips del usuario (backend)
  // ==========================================================
  Future<void> _loadTrips() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final upcoming = await _service.getUpcomingTrips();
      final past = await _service.getPastTrips();

      setState(() {
        _upcoming = upcoming;
        _past = past;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ==========================================================
  // MAIN UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trips"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Past trips"),
          ],
        ),
        actions: [
          // 🔄 Refresh (igual que pilotos)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrips,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    "Error loading trips:\n$_error",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // ====================================================
                    // UPCOMING TAB
                    // ====================================================
                    _upcoming.isEmpty
                        ? const UpcomingTripsEmpty()
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _upcoming.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final trip = _upcoming[index];
                              return TripCard(
                                  trip: trip,
                                  onDetails: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TripDetailsScreen(
                                          reservationId: trip.reservationId,
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),

                    // ====================================================
                    // PAST TAB
                    // ====================================================
                    _past.isEmpty
                        ? const PastTripsEmpty()
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _past.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final trip = _past[index];
                              return TripCard(
                                  trip: trip,
                                  onDetails: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TripDetailsScreen(
                                          reservationId: trip.reservationId,
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),
                  ],
                ),
    );
  }
}
