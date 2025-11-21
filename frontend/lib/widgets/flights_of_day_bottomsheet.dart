import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/company_flight_model.dart';

class FlightsOfDayBottomSheet extends StatelessWidget {
  final DateTime selectedDay;
  final List<CompanyFlightModel> flights;

  const FlightsOfDayBottomSheet({
    super.key,
    required this.selectedDay,
    required this.flights,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, d MMMM yyyy').format(selectedDay);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Text(
              'Flights on $dateLabel',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (flights.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('There are no flights scheduled for today.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: flights.length,
                  itemBuilder: (context, index) {
                    final flight = flights[index];
                    final departure = DateFormat.Hm()
                        .format(flight.departureTime.toLocal());
                    final arrival =
                        DateFormat.Hm().format(flight.arrivalTime.toLocal());

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.flight_takeoff,
                          color: Colors.blueAccent,
                        ),

                        title: Text(
                          '${flight.departureAirportName ?? 'Unknown'} → ${flight.arrivalAirportName ?? 'Unknown'}',
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$departure - $arrival'),
                            Text(flight.aircraftModel ?? ''),
                            const SizedBox(height: 6),

                            // ⭐ CREW INFO
                            if (flight.hasAssignedPilots)
                              Text(
                                'Crew assigned (${flight.assignedPilotCount})',
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else
                              const Text(
                                'No crew assigned',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),

                        isThreeLine: true,

                        trailing: Text(
                          flight.status,
                          style: TextStyle(
                            color: flight.status == 'Completed'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        onTap: () {
                          Navigator.pop(context, flight); // return selected flight
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
