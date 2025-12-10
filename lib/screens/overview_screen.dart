import 'package:flutter/material.dart';
import 'dart:math' as math;

// Fallback for GoogleFonts if package is missing/broken
class GoogleFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF166534), // Dark Green Header
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTempChartCard(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildRainfallCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSunlightCard()),
                        ],
                      ),
                      const SizedBox(height: 30), // Bottom padding
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 20, 25),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sensor Tower #1",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Location: Grid Sphere Pvt. Ltd.",
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFF4ADE80)),
                const SizedBox(width: 6),
                Text(
                  "Connected",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTempChartCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Temperature",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      "24 hr",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[600]),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          // Custom Curve Chart Placeholder
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _SmoothCurvePainter(),
            ),
          ),
          const SizedBox(height: 10),
          // Time Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["0h", "6h", "12h", "18h", "24h"]
                .map((t) => Text(
                      t,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRainfallCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily rainfall",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            "Last 7 days",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [2, 4, 3, 1.5, 2.5, 3, 1].map((val) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 8,
                    height: val * 20, // Scale height
                    decoration: BoxDecoration(
                      color: const Color(0xFF166534).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["S", "M", "T", "W", "T", "F", "S"]
                .map((d) => Text(
                      d,
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[400]),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSunlightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sunlight",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 100,
              height: 80,
              child: CustomPaint(
                painter: _GaugePainter(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Sunlight intensity",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painters for visuals ---

class _SmoothCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF166534)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    // Simulate the curve points
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.7, size.width * 0.2, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.35, size.height * 0.2, size.width * 0.5, size.height * 0.3); // Peak
    path.quadraticBezierTo(size.width * 0.65, size.height * 0.5, size.width * 0.75, size.height * 0.8); // Dip
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.4, size.width, size.height * 0.5);

    // Gradient Fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF166534).withOpacity(0.2),
        const Color(0xFF166534).withOpacity(0.0),
      ],
    );

    canvas.drawPath(fillPath, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    canvas.drawPath(path, paint);

    // Draw Points (Peak and Low)
    _drawPointLabel(canvas, size.width * 0.45, size.height * 0.25, "32°C", true);
    _drawPointLabel(canvas, size.width * 0.75, size.height * 0.8, "20°C", false);
  }

  void _drawPointLabel(Canvas canvas, double x, double y, String label, bool isTop) {
    final paint = Paint()..color = const Color(0xFF1F2937); // Dark point
    canvas.drawCircle(Offset(x, y), 4, paint);
    canvas.drawCircle(Offset(x, y), 8, paint..color = paint.color.withOpacity(0.2));

    // Label Badge
    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x, y - (isTop ? 20 : -20)), 
        width: textPainter.width + 12, 
        height: textPainter.height + 8
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(bgRect, Paint()..color = const Color(0xFF1F2937));
    textPainter.paint(
      canvas, 
      Offset(bgRect.left + 6, bgRect.top + 4)
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Value Arc
    final valuePaint = Paint()
      ..color = const Color(0xFF166534)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * 0.7, // 70% value
      false,
      valuePaint,
    );

    // Needle
    final needlePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;
    
    // Simple needle line for effect
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi * 0.3); // Rotate to match value
    canvas.drawRect(Rect.fromLTWH(-2, -radius + 15, 4, radius - 15), needlePaint);
    canvas.restore();
    
    canvas.drawCircle(center, 6, needlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}