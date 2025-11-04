import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar el provider
import 'package:http/http.dart' as http;
import 'package:frontend/screens/admin/company_management/company_management_screen.dart';
import 'package:frontend/screens/admin/company_pilots/company_pilots_screen.dart';
import 'package:frontend/screens/homepage_admin.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/screens/homepage_screen.dart';
import 'package:frontend/screens/homepage_pilot.dart';
import 'package:frontend/screens/homepage_admin_company.dart';
import 'package:frontend/screens/admin/user_management_screen.dart';
import 'package:frontend/screens/admin/company_fleet/fleet_management_screen.dart';
import 'package:frontend/providers/company_id_provider.dart'; // Importar el provider que creamos

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CompanyIdProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultScreen = const Center(child: CircularProgressIndicator());
  int? _companyId; // Guardamos el companyId localmente (para la navegación inicial)
  String? _companyName; // Guardamos el nombre de la empresa localmente

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      await TokenStorage.clearTokens();
      if (mounted) setState(() => _defaultScreen = const WelcomeScreen());
      return;
    }

    try {
      final profile = await _fetchProfileWithFallback(token);
      if (profile == null) {
        await TokenStorage.clearTokens();
        if (mounted) setState(() => _defaultScreen = const WelcomeScreen());
        return;
      }

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

      // Guardamos el companyId y companyName en el provider
      if (profile['companyId'] != null) {
        _companyId = profile['companyId'];
        await TokenStorage.saveCompanyId(_companyId); // Guardamos en TokenStorage
        Provider.of<CompanyIdProvider>(context, listen: false).companyId = _companyId;
      }

      if (profile['companyName'] != null) {
        _companyName = profile['companyName'];
        await TokenStorage.saveCompanyName(_companyName); // Guardamos en TokenStorage
      }

      if (mounted) {
        setState(() {
          if (roleName == 'admin' || roleId == 1) {
            _defaultScreen = const HomePageAdmin();
          } else if (roleName == 'companyadmin' || roleId == 2) {
            _defaultScreen = const HomePageAdminCompany();
          } else if (roleName == 'pilot' || roleId == 3) {
            _defaultScreen = const HomePagePilot();
          } else {
            _defaultScreen = const HomePageScreen();
          }
        });
      }
    } catch (e) {
      print('⚠️ Error al verificar token/perfil: $e');
      await TokenStorage.clearTokens();
      if (mounted) setState(() => _defaultScreen = const WelcomeScreen());
    }
  }

  Future<Map<String, dynamic>?> _fetchProfileWithFallback(String token) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Future<http.Response> _get(String path) =>
        http.get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: headers);

    // 1) intento con /api/users/profile (ruta correcta del back)
    http.Response res = await _get('/api/users/profile');

    if (res.statusCode == 200) {
      return _safeJson(res.body);
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      return null; // token inválido/expirado
    }

    // 2) fallback legacy: /users/me
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
      home: _defaultScreen, // La pantalla que se muestra por defecto
      routes: {
        '/user': (_) => const HomePageScreen(),
        '/pilot': (_) => const HomePagePilot(),
        '/admin': (_) => const HomePageAdmin(),
        '/admin/company': (_) => const HomePageAdminCompany(), // No pasamos companyId como parámetro
        '/admin/pilots': (_) => const CompanyPilotsScreen(), // No pasamos companyId como parámetro
        '/admin/company_management': (_) => const CompanyManagementScreen(),
        '/admin/users': (_) => const UserManagementScreen(),
        '/admin/fleet': (_) => const FleetManagementScreen(),
      },
    );
  }
}
