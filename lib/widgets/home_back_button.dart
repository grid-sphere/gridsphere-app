import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../screens/dashboard_screen.dart'; // Adjust path if needed based on structure

class HomeBackButton extends StatelessWidget {
  final Color color;

  const HomeBackButton({
    super.key,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(LucideIcons.arrowLeft, color: color),
      onPressed: () {
        // Navigate directly to Dashboard (Home) and clear stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      },
    );
  }
}
