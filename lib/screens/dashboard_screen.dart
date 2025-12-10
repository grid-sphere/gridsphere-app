import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import 'overview_screen.dart';
import 'profile_screen.dart'; // Import the new Profile Screen

// Fallback GoogleFonts class... (same as before)
class GoogleFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedDeviceId = "2";
  Map<String, dynamic>? sensorData;
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer =
        Timer.periodic(const Duration(seconds: 60), (timer) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    final data = {
      "temp": 28.0,
      "humidity": 65.0,
      "soil_moisture": 65,
      "crop_health": "Good",
      "pest_alert": "Low",
      "next_harvest": "15 Days",
      "watering": "Recommended",
    };
    setState(() {
      sensorData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF166534),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCustomHeader(context), // Pass context here
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF166534)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryTitle(),
                            const SizedBox(height: 20),
                            _buildMainVitalsCard(context),
                            const SizedBox(height: 16),
                            _buildOverviewButton(context),
                            const SizedBox(height: 16),
                            _buildActionGrid(),
                            const SizedBox(height: 16)
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to accept context and navigate to Profile
  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/logo.png',
                  width: 24,
                  height: 24,
                  // If the image fails to load (missing file), show the Icon instead
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.public, // Represents 'Grid Sphere'
                      size: 24,
                      color: Colors.white,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Grid Sphere Pvt. Ltd.",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "AgriTech",
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Profile Icon with Navigation
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD6C0B3), // Beige/Skin tone
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.person, color: Color(0xFF5D4037), size: 20),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Summary",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        Text(
          "Real-time farm data from sensor towers",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OverviewScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF166534),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 20),
            const SizedBox(width: 8),
            Text(
              "View Detailed Overview",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainVitalsCard(BuildContext context) {
    final int moisture = sensorData?['soil_moisture'] ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OverviewScreen()),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 10,
                                color: Colors.grey.shade100,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: moisture / 100,
                                strokeWidth: 10,
                                color: const Color(0xFF166534),
                                backgroundColor: Colors.transparent,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$moisture%",
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Soil Moisture",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 80,
                width: 1,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.thermostat,
                              size: 18, color: Colors.blue),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Temperature",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              "${sensorData?['temp']}°C",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.grass,
                              size: 18, color: Colors.green),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Crop health",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              "${sensorData?['crop_health']}",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: "Watering",
            subtitle: sensorData?['watering'] ?? "--",
            icon: Icons.opacity,
            iconColor: Colors.blue,
            bgColor: Colors.blue.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            title: "Pest Alert",
            subtitle: sensorData?['pest_alert'] ?? "--",
            icon: Icons.bug_report,
            iconColor: Colors.red,
            bgColor: Colors.red.withOpacity(0.1),
            subtitleColor: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            title: "Next Harvest",
            subtitle: sensorData?['next_harvest'] ?? "--",
            icon: Icons.inventory_2,
            iconColor: Colors.green,
            bgColor: Colors.green.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage(
              "https://img.freepik.com/free-vector/isometric-farm-elements-collection_23-2148520857.jpg?w=1380"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color? subtitleColor;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110, // Fixed height for alignment
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: subtitleColor ?? const Color(0xFF1F2937),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
