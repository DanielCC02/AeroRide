import 'package:frontend/screens/homepage_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // quita el banner de debug
      title: 'Aeroride',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
      home: const HomePageScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'core/styles.dart';
// import 'screens/welcome_screen.dart';

// void main() {
//   runApp(const AeroCaribeApp());
// }

// class AeroCaribeApp extends StatelessWidget {
//   const AeroCaribeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'AeroRide',
//       theme: AppTheme.light(),
//       debugShowCheckedModeBanner: false,
//       home: const WelcomeScreen(),
//     );
//   }
// }
