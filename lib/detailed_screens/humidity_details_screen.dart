import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Helper class for fonts
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

class HumidityDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? sensorData;

  const HumidityDetailsScreen({super.key, this.sensorData});

  @override
  State<HumidityDetailsScreen> createState() => _HumidityDetailsScreenState();
}

class _HumidityDetailsScreenState extends State<HumidityDetailsScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    // Extract data or use defaults
    final double currentHum = 65.0;
    final double maxHum = currentHum + 12.0;
    final double minHum = currentHum - 15.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Humidity Analysis",
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, color: Colors.black87, size: 20),
            onPressed: () {},
          )
        ],
      ),
      // Fixed Footer
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF166534),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) Navigator.pop(context);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: "Sensors"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Alerts"),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Insight Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE), // Light blue bg
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.bot, size: 20, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Text(
                        "AI Insight",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Humidity levels are stable. Risk of powdery mildew is moderate. Ensure good air circulation in the lower canopy.",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Time Filter Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab("Today", true),
                  _buildTab("Week", false),
                  _buildTab("Month", false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    "Max Humidity",
                    "${maxHum.toStringAsFixed(0)}%",
                    Icons.arrow_upward,
                    Colors.blue,
                    "05:00 AM",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox(
                    "Min Humidity",
                    "${minHum.toStringAsFixed(0)}%",
                    Icons.arrow_downward,
                    Colors.orange,
                    "02:30 PM",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Humidity Trend (Today)",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _HumidityChartPainter(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _axisLabel("0:00"),
                      _axisLabel("6:00"),
                      _axisLabel("12:00"),
                      _axisLabel("18:00"),
                      _axisLabel("24:00"),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Additional Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    "Dew Point",
                    "18.5°C",
                    LucideIcons.droplets,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    "Vapor Pressure",
                    "1.8 kPa",
                    LucideIcons.cloudFog,
                    Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF166534) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon, Color color, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _axisLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 11),
    );
  }
}

// Custom Painter for Humidity (Blue Theme)
class _HumidityChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withOpacity(0.2),
          Colors.blue.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    // Start high (morning dew)
    path.moveTo(0, size.height * 0.2);
    // Dip down (afternoon heat)
    path.cubicTo(
      size.width * 0.3, size.height * 0.2, 
      size.width * 0.4, size.height * 0.8, 
      size.width * 0.6, size.height * 0.8
    );
    // Rise up (evening)
    path.cubicTo(
      size.width * 0.8, size.height * 0.8, 
      size.width * 0.9, size.height * 0.3, 
      size.width, size.height * 0.25
    );

    // Draw shadow/fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw Horizontal Grid Lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;
    for(int i=0; i<5; i++) {
      double y = size.height * (i/4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}