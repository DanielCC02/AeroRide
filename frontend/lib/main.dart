import 'dart:convert';
import 'package:frontend/screens/admin/fleet_management_screen.dart';
import 'package:frontend/screens/admin/user_management_screen.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/homepage_admin.dart';
import 'package:frontend/screens/homepage_pilot.dart';
import 'package:frontend/screens/homepage_screen.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/services/token_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultScreen = const Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// Verifica si hay un token guardado para decidir la pantalla inicial.
  Future<void> _checkLoginStatus() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) {
      setState(() => _defaultScreen = const WelcomeScreen());
      return;
    }

    try {
      // Llama al endpoint para obtener el perfil
      final url = Uri.parse('${ApiConfig.baseUrl}/api/users/me');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roleName = (data['role'] ?? '').toString().toLowerCase();

        setState(() {
          if (roleName == 'admin') {
            _defaultScreen = const HomePageAdmin();
          } else if (roleName == 'pilot') {
            _defaultScreen = const HomePagePilot();
          } else {
            _defaultScreen = const HomePageScreen();
          }
        });
      } else {
        // Token inválido o expirado
        await TokenStorage.clearTokens();
        setState(() => _defaultScreen = const WelcomeScreen());
      }
    } catch (e) {
      print('⚠️ Error al verificar token: $e');
      setState(() => _defaultScreen = const WelcomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aeroride',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,

        /// 🔹 Restauramos tu configuración original del BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
      home: _defaultScreen,
      routes: {
        '/user': (_) => const HomePageScreen(),
        '/pilot': (_) => const HomePagePilot(),
        '/admin': (_) => const HomePageAdmin(),
        // Ruta para gestión de usuarios (ADMIN)
        '/admin/users': (_) => const UserManagementScreen(),
        // Ruta para gestión de la flota (ADMIN)
        '/admin/fleet': (_) => const FleetManagementScreen(),
      },
    );
  }
}
