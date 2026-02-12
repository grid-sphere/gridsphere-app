import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../screens/dashboard_screen.dart';
import '../agriculture/protection_screen.dart';
import '../agriculture/soil_screen.dart';
import '../cement/cement_dust_spread_screen.dart';
import '../cement/cement_emission_screen.dart';
import '../chemical/chemical_dust_spread_screen.dart';
import '../chemical/chemical_process_stability_screen.dart';
import '../screens/alerts_screen.dart';
import '../session_manager/session_manager.dart';

class GoogleFontsHelper {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String deviceId;
  final Map<String, dynamic>? sensorData;
  final double latitude;
  final double longitude;
  final List<BottomNavigationBarItem>? items;
  final void Function(int)? onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.deviceId = "",
    this.sensorData,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.items,
    this.onItemTapped,
  });

  List<BottomNavigationBarItem> _getItemsForRole(String role) {
    switch (role) {
      case 'cement':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.wind), label: "Dust Risk"),
          BottomNavigationBarItem(icon: SizedBox(height: 24), label: ""),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.activity), label: "Emission"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none), label: "Alerts"),
        ];
      case 'chemical':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.wind), label: "Pollution"),
          BottomNavigationBarItem(icon: SizedBox(height: 24), label: ""),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.gauge), label: "Stability"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none), label: "Alerts"),
        ];
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.shieldCheck), label: "Protection"),
          BottomNavigationBarItem(icon: SizedBox(height: 24), label: ""),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.layers), label: "Soil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none), label: "Alerts"),
        ];
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 2 || index == currentIndex) return;

    final String role = SessionManager().role;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      switch (role) {
        case 'cement':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CementDustSpreadScreen(deviceId: deviceId),
            ),
          );
          break;
        case 'chemical':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChemicalDustSpreadScreen(deviceId: deviceId),
            ),
          );
          break;
        default:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProtectionScreen(deviceId: deviceId),
            ),
          );
      }
    } else if (index == 3) {
      switch (role) {
        case 'cement':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CementEmissionScreen(deviceId: deviceId),
            ),
          );
          break;
        case 'chemical':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChemicalProcessStabilityScreen(deviceId: deviceId),
            ),
          );
          break;
        default:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SoilScreen(
                deviceId: deviceId,
                sensorData: sensorData,
                latitude: latitude,
                longitude: longitude,
              ),
            ),
          );
      }
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlertsScreen(
            deviceId: deviceId,
            sensorData: sensorData,
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String role = SessionManager().role;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF166534),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle:
          GoogleFontsHelper.inter(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: GoogleFontsHelper.inter(fontSize: 12),
      onTap: onItemTapped ?? (index) => _onItemTapped(context, index),
      items: items ?? _getItemsForRole(role),
    );
  }
}
