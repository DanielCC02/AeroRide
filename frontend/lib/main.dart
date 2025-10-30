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
  /// Si no hay token o el perfil falla, limpia tokens y va a Welcome.
  Future<void> _checkLoginStatus() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      // Asegura que no quede nada viejo antes de ir a Welcome
      await TokenStorage.clearTokens();
      if (mounted) setState(() => _defaultScreen = const WelcomeScreen());
      return;
    }

    try {
      final profile = await _fetchProfileWithFallback(token);
      if (profile == null) {
        // Token inválido/expirado o no se pudo obtener el perfil
        await TokenStorage.clearTokens();
        if (mounted) setState(() => _defaultScreen = const WelcomeScreen());
        return;
      }

      // role puede venir como:
      // 1) string directo: "Admin"
      // 2) objeto: { id: 1, name: "Admin" }
      // 3) además, puede venir roleId suelto
      String roleName = '';
      int? roleId;

      final roleField = profile['role'];
      if (roleField is String) {
        roleName = roleField.toLowerCase();
      } else if (roleField is Map) {
        if (roleField['name'] is String) {
          roleName = (roleField['name'] as String).toLowerCase();
        }
        if (roleField['id'] is int) {
          roleId = roleField['id'] as int;
        }
      }
      if (roleId == null && profile['roleId'] is int) {
        roleId = profile['roleId'] as int;
      }

      if (mounted) {
        setState(() {
          if (roleName == 'admin' || roleId == 1) {
            _defaultScreen = const HomePageAdmin();
          } else if (roleName == 'pilot' || roleId == 2) {
            _defaultScreen = const HomePagePilot();
          } else {
            _defaultScreen = const HomePageScreen();
          }
        });
      }
    } catch (e) {
      // En cualquier error, vuelve a welcome y limpia tokens para evitar estados raros
      // ignore: avoid_print
      print('⚠️ Error al verificar token/perfil: $e');
      await TokenStorage.clearTokens();
      if (mounted) setState(() => _defaultScreen = const WelcomeScreen());
    }
  }

  /// Intenta primero /api/users/profile y si devuelve 404/405,
  /// reintenta en /users/me (por compatibilidad antigua).
  /// Devuelve el JSON del perfil o null si 401/403 u otro error.
  Future<Map<String, dynamic>?> _fetchProfileWithFallback(String token) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Future<http.Response> get(String path) =>
        http.get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: headers);

    // 1) intento con /api/users/profile (ruta correcta del back)
    http.Response res = await get('/api/users/profile');

    if (res.statusCode == 200) {
      return _safeJson(res.body);
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      return null; // token inválido/expirado
    }

    // 2) fallback legacy: /users/me
    if (res.statusCode == 404 || res.statusCode == 405) {
      res = await get('/users/me');
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
