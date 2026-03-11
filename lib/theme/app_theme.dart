import 'package:flutter/material.dart';
import '../session_manager/session_manager.dart';

class AppTheme {
  // Centralized dynamic primary color based on Industry
  static Color get primaryColor {
    final String role = SessionManager().role;

    switch (role) {
      case 'cement':
        return const Color(0xFF1E3A8A); // Deep Blue for Cement
      case 'chemical':
        return const Color(0xFF7C3AED); // Purple for Chemical
      case 'agriculture':
      default:
        return const Color(0xFF166534); // Dark Green for Agriculture
    }
  }

  // Dynamic light background color for containers and icon backgrounds
  static Color get lightBackgroundColor {
    final String role = SessionManager().role;

    switch (role) {
      case 'cement':
        return const Color(0xFFDBEAFE); // Light Blue
      case 'chemical':
        return const Color(0xFFF3E8FF); // Light Purple
      case 'agriculture':
      default:
        return const Color(0xFFE8F5E9); // Light Green
    }
  }

  // Dynamic icon representation for the industry
  static IconData get industryIcon {
    final String role = SessionManager().role;

    switch (role) {
      case 'cement':
        return Icons.factory;
      case 'chemical':
        return Icons.science;
      case 'agriculture':
      default:
        return Icons.eco;
    }
  }
}
