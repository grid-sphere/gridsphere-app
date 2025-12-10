import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; 

void main() {
  runApp(const GridSphereApp());
}

class GridSphereApp extends StatelessWidget {
  const GridSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid Sphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF166534),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        useMaterial3: true,
      ),
      // Set SplashScreen as the starting home screen
      home: const SplashScreen(),
    );
  }
}