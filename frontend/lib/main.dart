import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/screens/admin/airport_management/airport_management_screen.dart';
import 'package:frontend/screens/admin/company_flights_management/flight_schedule_screen.dart';
import 'package:frontend/screens/admin/company_management/company_management_screen.dart';
import 'package:frontend/screens/admin/company_pilots/company_pilots_screen.dart';
import 'package:frontend/screens/homepage_admin.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/screens/homepage_screen.dart';
import 'package:frontend/screens/homepage_pilot.dart';
import 'package:frontend/screens/homepage_admin_company.dart';
import 'package:frontend/screens/admin/company_fleet/fleet_management_screen.dart';
import 'package:frontend/providers/company_id_provider.dart';
import 'package:frontend/providers/client_provider.dart';

void main() {
  // TOMAS
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // se desactiva automáticamente en release
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CompanyIdProvider()),
          ChangeNotifierProvider(create: (_) => ClientProvider()..load()),
        ],
        child: const MyApp(),
      ),
    ),
  );
  /* TIFFER
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompanyIdProvider()),
        ChangeNotifierProvider(
          create: (_) => ClientProvider()..load(), // carga userId al inicio
        ),
      ],
      child: const MyApp(),
    ),
  ); */
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultScreen = const Center(child: CircularProgressIndicator());
  int? _companyId;
  String? _companyName;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      await TokenStorage.clearTokens();
      if (mounted) {
        setState(() => _defaultScreen = const WelcomeScreen());
      }
      return;
    }

    try {
      final profile = await _fetchProfileWithFallback(token);
      if (profile == null) {
        await TokenStorage.clearTokens();
        if (mounted) {
          setState(() => _defaultScreen = const WelcomeScreen());
        }
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

      // Guardamos el companyId y companyName en el provider/TokenStorage
      if (profile['companyId'] != null) {
        _companyId = profile['companyId'] as int?;
        await TokenStorage.saveCompanyId(_companyId);

        // 👇 evitar use_build_context_synchronously
        if (mounted && _companyId != null) {
          context.read<CompanyIdProvider>().companyId = _companyId;
        }
      }

      if (profile['companyName'] != null) {
        _companyName = profile['companyName'] as String?;
        await TokenStorage.saveCompanyName(_companyName);
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
      if (kDebugMode) {
        debugPrint('⚠️ Error al verificar token/perfil: $e');
      }
      await TokenStorage.clearTokens();
      if (mounted) {
        setState(() => _defaultScreen = const WelcomeScreen());
      }
    }
  }

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
      return null;
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

      // IMPORTANTE PARA DevicePreview
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      home: _defaultScreen,
      routes: {
        '/user': (_) => const HomePageScreen(),
        '/pilot': (_) => const HomePagePilot(),
        '/admin': (_) => const HomePageAdmin(),
        '/admin/company': (_) => const HomePageAdminCompany(),
        '/admin/pilots': (_) => const CompanyPilotsScreen(),
        '/admin/company_management': (_) => const CompanyManagementScreen(),
        '/admin/airport_management': (_) => const AirportManagementScreen(),
        '/admin/fleet': (_) => const FleetManagementScreen(),
        '/admin/flight-schedule': (_) => const FlightScheduleScreen(),
      },
    );
  }
}