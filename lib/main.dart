import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import '../auth_screens/splash_screen.dart';
import 'services/background_service.dart'; // Import Background Service
import 'services/notification_service.dart'; // Import Notification Service

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize the Notification Service
  await NotificationService.initialize();

  // 3. Initialize the Background Service (Critical for preventing the crash)
  await BackgroundService.initialize();

  // OPTIONAL: Register task immediately on app start to ensure it runs even if user doesn't go to Alert settings.
  // Ideally, this should be gated by a check if alerts are actually enabled in preferences.
  // For now, registering it here ensures the worker is alive.
  BackgroundService.registerPeriodicTask();

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
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
