import 'package:flutter/material.dart';
import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/screens/pilot/view_flight_log_screen.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/services/pilot_flight_service.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:frontend/widgets/pilot/pilot_flight_card.dart';
import 'package:frontend/widgets/pilot/pilot_flight_card_past.dart';
import 'package:frontend/widgets/pilot/upcoming_flights_empty.dart';
import 'package:frontend/widgets/pilot/past_flights_empty.dart';

class HomePagePilot extends StatefulWidget {
  const HomePagePilot({super.key});

  @override
  State<HomePagePilot> createState() => _HomePagePilotState();
}

class _HomePagePilotState extends State<HomePagePilot>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PilotFlightService _service = PilotFlightService();

  List<CompanyFlightModel> _upcoming = [];
  List<CompanyFlightModel> _past = [];

  /// Mapa para saber si un vuelo tiene bitácora
  Map<int, bool> _logsMap = {};

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFlights();
  }

  /// ==========================================================
  /// Cargar vuelos y bitácoras
  /// ==========================================================
  Future<void> _loadFlights() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final pilotId = await TokenStorage.getUserId();
      if (pilotId == null) throw Exception("User ID not found");

      final flights = await _service.getFlightsByPilot(pilotId);
      final now = DateTime.now();

      // 🔥 REGLA FINAL
      _past = flights
          .where(
            (f) => f.status == "Completed" || f.departureTime.isBefore(now),
          )
          .toList();

      _upcoming = flights
          .where((f) => f.status != "Completed" && f.departureTime.isAfter(now))
          .toList();

      // Ver si tienen bitácora
      _logsMap = {};
      for (final f in flights) {
        final hasLog = await _service.flightHasLog(f.id);
        _logsMap[f.id] = hasLog;
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// ==========================================================
  /// MAIN UI
  /// ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Flights"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Past flights"),
          ],
        ),
        actions: [
          // 🔄 Recarga
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFlights),

          // 🔐 Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await TokenStorage.clearTokens();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                "Error loading flights:\n$_error",
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
                    ? const PilotUpcomingEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _upcoming.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final flight = _upcoming[index];
                          final hasLog = _logsMap[flight.id] ?? false;

                          //  Si el vuelo ya está COMPLETED, mostrar versión past
                          if (flight.status == "Completed") {
                            return PilotFlightCardPast(
                              flight: flight,
                              onViewLog: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ViewFlightLogScreen(flight: flight),
                                  ),
                                );
                              },
                            );
                          }

                          // Si NO está completed → PilotFlightCard
                          return PilotFlightCard(
                            flight: flight,
                            hasLog: hasLog,
                            onReload: _loadFlights,
                          );
                        },
                      ),

                // ====================================================
                // PAST TAB
                // ====================================================
                _past.isEmpty
                    ? const PilotPastEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _past.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final flight = _past[index];
                          return PilotFlightCardPast(
                            flight: flight,
                            onViewLog: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ViewFlightLogScreen(flight: flight),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
    );
  }
}
