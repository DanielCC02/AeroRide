import 'package:flutter/material.dart';
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
  Widget _defaultScreen = const CircularProgressIndicator();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await TokenStorage.getAccessToken();
    setState(() {
      _defaultScreen =
          token != null ? const HomePageScreen() : const WelcomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aeroride',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        body: Center(child: _defaultScreen),
      ),
    );
  }
}
