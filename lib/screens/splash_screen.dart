import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart'; // Updated import to LoginScreen

// Fallback GoogleFonts class (Same as in dashboard)
class GoogleFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    
    // Simple fade-in animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Navigate to LoginScreen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF166534), // Brand Green
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Circle
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Image.asset(
                  'assets/logo.png', 
                  width: 64,
                  height: 64,
                  // If the image fails to load (missing file), show the Icon instead
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.public, // Represents 'Grid Sphere'
                      size: 64,
                      color: Colors.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              
              // Company Name
              Text(
                "Grid Sphere Pvt. Ltd.",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                "AgriTech Solutions",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}