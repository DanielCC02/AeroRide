// lib/screens/homepage_screen.dart

import 'package:flutter/material.dart';

import '../widgets/search_form.dart';
import '../widgets/custom_bottom_nav.dart';
import '../screens/trips_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile/profile_tab.dart';
import '../services/token_storage.dart';
import '../screens/welcome_screen.dart';
import '../widgets/todays_deals_section.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _BookTab(), // Book (search + today's deals)
    TripsScreen(), // Trips
    MapScreen(), // Map
    ProfileTab(), // Profile ✅
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.jpg", height: 40),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "AERO",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 252, 102, 92),
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  const TextSpan(
                    text: "RIDE",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Cerrar sesión',
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
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Tab principal de "Book": SearchForm + Today's Deals
class _BookTab extends StatelessWidget {
  const _BookTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          SearchForm(),
          SizedBox(height: 16),
          TodaysDealsSection(),
        ],
      ),
    );
  }
}
