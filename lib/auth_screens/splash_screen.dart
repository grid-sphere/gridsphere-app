import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../session_manager/session_manager.dart';
import 'package:google_fonts/google_fonts.dart'; // The real package
import '../theme/app_theme.dart'; // Import AppTheme

// --- FIX: Use 'hide GoogleFonts' to ignore the local helpers in these files ---
import 'login_screen.dart' hide GoogleFonts;
import '../screens/dashboard_screen.dart' hide GoogleFonts;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  final String _baseUrl = "https://gridsphere.in/station/api";

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for animation/branding
    await Future.delayed(const Duration(seconds: 3));

    // Check for saved cookie
    final prefs = await SharedPreferences.getInstance();
    final String? sessionCookie = prefs.getString('session_cookie');

    if (mounted) {
      if (sessionCookie != null && sessionCookie.isNotEmpty) {
        // --- Set session in Singleton ---
        SessionManager().setSessionCookie(sessionCookie);

        // Fetch devices first to get the active device ID
        await _fetchDevicesAndIndustry(sessionCookie);

        // Cookie found -> Go to Dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // No cookie -> Go to Login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _fetchDevicesAndIndustry(String cookie) async {
    try {
      final devicesResponse = await http.get(
        Uri.parse('$_baseUrl/getDevices'),
        headers: {
          'Cookie': cookie,
          'User-Agent': 'FlutterApp',
        },
      );

      if (devicesResponse.statusCode == 200) {
        final devicesData = jsonDecode(devicesResponse.body);
        List<dynamic> deviceList = [];

        if (devicesData is List) {
          deviceList = devicesData;
        } else if (devicesData is Map && devicesData.containsKey('data')) {
          if (devicesData['data'] is List) {
            deviceList = devicesData['data'] as List;
          }
        }

        if (deviceList.isNotEmpty) {
          var firstDevice = deviceList[0];
          String deviceId = firstDevice['d_id']?.toString() ?? "";

          if (deviceId.isNotEmpty) {
            SessionManager().setDeviceId(deviceId);
            await _fetchIndustryType(cookie, deviceId);
          } else {
            // Fallback to local storage if no device is found
            await SessionManager().loadRole();
          }
        } else {
          // Fallback to local storage if no devices are returned
          await SessionManager().loadRole();
        }
      } else {
        // Fallback on error
        await SessionManager().loadRole();
      }
    } catch (e) {
      debugPrint("Error fetching devices on splash: $e");
      await SessionManager().loadRole();
    }
  }

  String _mapValueToRole(int val) {
    if (val == 1) return 'agriculture';
    if (val == 2) return 'cement';
    return 'chemical'; // 0 or others
  }

  Future<void> _fetchIndustryType(String cookie, String deviceId) async {
    try {
      final industryResponse = await http.get(
        Uri.parse('$_baseUrl/devices/$deviceId/industry'),
        headers: {
          'Cookie': cookie,
          'User-Agent': 'FlutterApp',
        },
      );

      if (industryResponse.statusCode == 200) {
        final indData = jsonDecode(industryResponse.body);

        if (indData['status'] == true && indData['data'] != null) {
          // Extract mapped integer (0, 1, 2)
          int indValue = int.tryParse(
                  indData['data']['industry_value']?.toString() ?? '1') ??
              1;
          String fetchedRole = _mapValueToRole(indValue);

          SessionManager().setRole(fetchedRole);
          SessionManager().setIndustryValue(indValue);
          await SessionManager().saveRole(fetchedRole, industryValue: indValue);

          debugPrint(
              "Industry type fetched successfully on app open: $fetchedRole (Value: $indValue)");
        } else {
          // Fallback if data is missing
          await SessionManager().loadRole();
        }
      } else {
        // Fallback on API error
        await SessionManager().loadRole();
      }
    } catch (e) {
      debugPrint("Error fetching industry type on splash: $e");
      // Fallback on exception
      await SessionManager().loadRole();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- DYNAMIC BACKGROUND COLOR ---
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2)),
                child: Image.asset('assets/logo.png',
                    width: 64,
                    height: 64,
                    errorBuilder: (c, e, s) => const Icon(Icons.public,
                        size: 64, color: Colors.white)),
              ),
              const SizedBox(height: 30),

              // --- Title with Bruno Ace SC ---
              Text(
                "Grid Sphere",
                textAlign: TextAlign.center,
                style: GoogleFonts.brunoAceSc(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // --- Subtitle with Bruno Ace SC ---
              Text(
                "Technologies",
                textAlign: TextAlign.center,
                style: GoogleFonts.brunoAceSc(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 60),
              const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3),
            ],
          ),
        ),
      ),
    );
  }
}
