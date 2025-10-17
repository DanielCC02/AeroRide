import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/token_storage.dart';

import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/screens/homepage_screen.dart';
import 'package:frontend/screens/homepage_pilot.dart';
import 'package:frontend/screens/homepage_admin.dart';
import 'package:frontend/screens/admin/user_management_screen.dart';
import 'package:frontend/screens/admin/fleet_management_screen.dart';

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

    if (token == null || token.isEmpty) {
      setState(() => _defaultScreen = const WelcomeScreen());
      return;
    }

    try {
      final profile = await _fetchProfileWithFallback(token);
      if (profile == null) {
        // Token inválido/expirado o no se pudo obtener el perfil
        await TokenStorage.clearTokens();
        setState(() => _defaultScreen = const WelcomeScreen());
        return;
      }

      // role puede venir como string directo o como objeto { name: "Admin" }
      String roleName = '';
      final roleField = profile['role'];
      if (roleField is String) {
        roleName = roleField.toLowerCase();
      } else if (roleField is Map && roleField['name'] is String) {
        roleName = (roleField['name'] as String).toLowerCase();
      }

      setState(() {
        if (roleName == 'admin') {
          _defaultScreen = const HomePageAdmin();
        } else if (roleName == 'pilot') {
          _defaultScreen = const HomePagePilot();
        } else {
          _defaultScreen = const HomePageScreen();
        }
      });
    } catch (e) {
      // En cualquier error, vuelve a welcome
      // ignore: avoid_print
      print('⚠️ Error al verificar token/perfil: $e');
      setState(() => _defaultScreen = const WelcomeScreen());
    }
  }

  /// Intenta primero /api/users/me y si devuelve 404/405/NotFound,
  /// reintenta en /users/me (sin /api). Devuelve el JSON del perfil o null.
  Future<Map<String, dynamic>?> _fetchProfileWithFallback(String token) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Future<http.Response> _get(String path) =>
        http.get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: headers);

    // 1) intento con /api/users/me
    http.Response res = await _get('/api/users/me');

    // Si está OK
    if (res.statusCode == 200) {
      return _safeJson(res.body);
    }

    // Si es 401/403, token no válido: devolver null
    if (res.statusCode == 401 || res.statusCode == 403) {
      return null;
    }

    // 2) fallback con /users/me (sin /api) si el primero no sirve
    if (res.statusCode == 404 || res.statusCode == 405) {
      res = await _get('/users/me');
      if (res.statusCode == 200) {
        return _safeJson(res.body);
      }
      if (res.statusCode == 401 || res.statusCode == 403) {
        return null;
      }
    }

    // Cualquier otro caso: considera que falló
    return null;
  }

  Map<String, dynamic>? _safeJson(String body) {
    try {
      final data = jsonDecode(body);
      return (data is Map<String, dynamic>) ? data : null;
    } catch (_) {
      return null;
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
        // ADMIN
        '/admin/users': (_) => const UserManagementScreen(),
        '/admin/fleet': (_) => const FleetManagementScreen(),
      },
    );
  }
}
