import 'package:flutter/material.dart';
import '../widgets/upcoming_trips_empty.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UpcomingTripsEmpty(), // widget separado
          Center(child: Text("Past trips will be shown here")),
        ],
      ),
    );
  }
}