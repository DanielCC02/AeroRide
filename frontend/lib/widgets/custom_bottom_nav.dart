import 'package:flutter/material.dart';

/// CustomBottomNav
/// -----------------------------
/// Widget personalizado para la barra de navegación inferior.
/// - Recibe el índice actual [currentIndex] para saber qué ítem está activo.
/// - Recibe la función [onTap] que se ejecuta al presionar un ítem.
/// 
/// Este widget se puede reutilizar en todas las pantallas que necesiten
/// navegación inferior consistente.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;        // Índice del ítem seleccionado actualmente
  final Function(int) onTap;     // Callback que se ejecuta al tocar un ítem

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Marca visual del ítem activo
      onTap: onTap,               // Llama a la función que cambia el índice

      // Ítems de navegación disponibles en la app
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.book),    // Icono de reservas
          label: "Book",             // Texto debajo del icono
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flight_takeoff), // Icono de vuelos/trips
          label: "Trips",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),     // Icono para el módulo del mapa
          label: "Map",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),  // Icono para perfil de usuario
          label: "Profile",
        ),
      ],
    );
  }
}