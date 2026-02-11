import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_ui_screen.dart';
import 'screens/register_ui_screen.dart';
import 'screens/password_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/dashboard_layout_screen.dart';
import 'screens/alert_settings_screen.dart';




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
        // Use a slight off-white/grey for the scaffold to make white cards pop
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), 
        useMaterial3: true,
        // Define a default card theme
        // Updated to CardThemeData based on the error message for your SDK version
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
      // home: const SplashScreen(),
      //home: const OnboardingUIScreen(),
      //home: const RegisterUIScreen(),
      //home: const PasswordScreen(),
      //home: const SettingsScreen(),
      home: const DashboardLayoutScreen(),
      //home: const AlertSettingsScreen(),
    );
  }
}