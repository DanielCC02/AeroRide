import 'package:flutter/material.dart';
import 'package:frontend/models/company_flight_model.dart';
import 'package:frontend/providers/company_id_provider.dart';
import 'package:frontend/screens/admin/company_flights_management/flight_detail_screen.dart';
import 'package:frontend/services/company_flight_service.dart';
import 'package:frontend/widgets/flights_of_day_bottomsheet.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class FlightScheduleScreen extends StatefulWidget {
  const FlightScheduleScreen({super.key});

  @override
  State<FlightScheduleScreen> createState() => _FlightScheduleScreenState();
}

class _FlightScheduleScreenState extends State<FlightScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final CompanyFlightService _flightService = CompanyFlightService();

  List<CompanyFlightModel> _flights = [];
  Set<DateTime> _eventDays = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    final companyId = context.read<CompanyIdProvider>().companyId;
    if (companyId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final flights = await _flightService.getFlightsByCompany(companyId);

      final daysWithFlights = flights
          .map((f) =>
              DateTime(f.departureTime.year, f.departureTime.month, f.departureTime.day))
          .toSet();

      setState(() {
        _flights = flights;
        _eventDays = daysWithFlights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  bool _hasEvent(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _eventDays.contains(d);
  }

  List<CompanyFlightModel> _flightsForDay(DateTime day) {
    return _flights.where((f) {
      final d = DateTime(f.departureTime.year, f.departureTime.month, f.departureTime.day);
      return d == DateTime(day.year, day.month, day.day);
    }).toList();
  }

 Future<void> _showFlightsModal(DateTime day) async {
    final flightsOfDay = _flightsForDay(day);

    final selectedFlight = await showModalBottomSheet<CompanyFlightModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FlightsOfDayBottomSheet(
        selectedDay: day,
        flights: flightsOfDay,
      ),
    );

    if (selectedFlight != null) {
      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlightDetailScreen(flight: selectedFlight),
        ),
      );

      if (updated == true) {
        await _loadFlights();
        setState(() {});
      }
    }
}

  @override
  Widget build(BuildContext context) {
    //final companyId = context.watch<CompanyIdProvider>().companyId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Schedule'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar vuelos',
            onPressed: _loadFlights,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(
                      'Error al cargar vuelos:\n$_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //if (companyId != null)
                        //Text('Company ID: $companyId',
                            //style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2000, 1, 1),
                            lastDay: DateTime.utc(2100, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              if (_hasEvent(selectedDay)) {
                                _showFlightsModal(selectedDay);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('There are no flights registered that day.'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            headerStyle: const HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                            ),
                            calendarStyle: CalendarStyle(
                              isTodayHighlighted: true,
                              markerDecoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            eventLoader: (day) =>
                                _hasEvent(day) ? ['flight'] : [],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          _LegendDot(),
                          SizedBox(width: 6),
                          Text('Days with flights'),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        _eventDays.isEmpty
                            ? 'No flights registered.'
                            : 'Tap a day with a marker to see the flights.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
      ),
    );
  }
}
