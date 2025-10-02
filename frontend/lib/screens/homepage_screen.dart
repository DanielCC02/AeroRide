import 'package:flutter/material.dart';
import '../widgets/search_form.dart';
import '../widgets/custom_bottom_nav.dart';
import '../screens/trips_screen.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas que corresponden a cada ítem del BottomNavigationBar
  final List<Widget> _screens = const [
    Padding(
      padding: EdgeInsets.all(16.0),
      child: SearchForm(), // Book
    ),
    TripsScreen(), // Trips
    Center(child: Text("Map screen placeholder")), // Map
    Center(child: Text("Profile screen placeholder")), // Profile
  ];

  // Cambiar el índice de la pantalla según el ícono seleccionado
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
            // Logo de Aeroride
            Image.asset(
              "assets/images/logo.jpg", // tu logo aquí
              height: 40,
            ),
            const SizedBox(width: 8),
            // Nombre de la app separando 'Aero' y 'Ride'
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "AERO",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 252, 102, 92),
                      fontWeight: FontWeight.w600, // semi-bold
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: "RIDE",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold, // bold
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
      ),
      // Mostrar pantalla según el índice seleccionado
      body: _screens[_selectedIndex],
      // Barra de navegación inferior
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
