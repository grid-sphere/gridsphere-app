import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http; // Add http package
import 'dart:convert'; // Add JSON decoding
import 'dart:async';
import 'dart:math'; // Imported for random data generation
import 'profile_screen.dart';
import 'chat_screen.dart';
import '../detailed_screens/temperature_details_screen.dart';
import '../detailed_screens/humidity_details_screen.dart';
import 'alerts_screen.dart';

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
  // --- Receive Session Cookie from Login ---
  final String sessionCookie;
  
  const DashboardScreen({super.key, required this.sessionCookie});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedDeviceId = ""; // Start empty
  Map<String, dynamic>? sensorData;
  List<double> tempHistory = []; // Store 24h temp history
  bool isLoading = true;
  Timer? _timer;
  int _selectedIndex = 0;
  
  final String _baseUrl = "https://gridsphere.in/station/api";

  @override
  void initState() {
    super.initState();
    debugPrint("Dashboard initialized with Cookie: ${widget.sessionCookie}");
    _initializeData();
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) => _fetchLiveData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _fetchDevices();
    if (selectedDeviceId.isNotEmpty) {
      await _fetchLiveData();
      await _fetchHistoryData(); // Fetch history for the graph
    } else {
      // If fetching devices failed, load mock data so UI isn't empty
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Connection failed. Showing Offline Data."),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
         );
      }
      _loadMockData(); 
    }
  }

  // Helper to load mock data if API fails
  void _loadMockData() {
    debugPrint("⚠️ Loading Mock Data (Fallback)");
    final random = Random();
    final data = {
      "air_temp": double.parse((24.0 + random.nextDouble() * 2 - 1).toStringAsFixed(1)),
      "humidity": 65 + random.nextInt(6) - 3,
      "leaf_wetness": random.nextDouble() > 0.9 ? "Wet" : "Dry",
      "soil_temp": double.parse((20.0 + random.nextDouble()).toStringAsFixed(1)),
      "soil_moisture": 30 + random.nextInt(5),
      "rainfall": double.parse((5.2 + (random.nextDouble() * 0.2)).toStringAsFixed(1)),
      "light_intensity": 850 + random.nextInt(50) - 25,
      "wind": double.parse((12.0 + random.nextDouble() * 3).toStringAsFixed(1)),
      "pressure": 1013 + random.nextInt(4) - 2,
      "depth_temp": double.parse((22.5 + random.nextDouble() * 0.5).toStringAsFixed(1)),
      "depth_humidity": double.parse((60.0 + random.nextDouble() * 2).toStringAsFixed(1)),
      "surface_temp": double.parse((26.0 + random.nextDouble()).toStringAsFixed(1)),
      "surface_humidity": double.parse((55.0 + random.nextDouble() * 2).toStringAsFixed(1)),
    };

    // Mock history data (24 points for 24 hours)
    List<double> mockHistory = List.generate(24, (index) => 20.0 + random.nextDouble() * 10);

    if (mounted) {
      setState(() {
        sensorData = data;
        tempHistory = mockHistory;
        isLoading = false;
        // If device ID failed to load, set a dummy one for UI
        if (selectedDeviceId.isEmpty) selectedDeviceId = "2 (Demo)";
      });
    }
  }

  Future<void> _fetchDevices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getDevices'),
        headers: {
          'Cookie': widget.sessionCookie,
          'User-Agent': 'FlutterApp', 
          'Accept': 'application/json',
        },
      );

      debugPrint("GetDevices Status: ${response.statusCode}");
      debugPrint("GetDevices Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> deviceList = [];

        // --- FIX: Robust Parsing for List or Map ---
        if (data is List) {
          deviceList = data;
        } else if (data is Map) {
           // Handle wrapped responses like {"data": [...]} or {"devices": [...]}
           if (data['data'] is List) {
             deviceList = data['data'];
           } else if (data['devices'] is List) {
             deviceList = data['devices'];
           }
        }

        if (deviceList.isNotEmpty) {
           setState(() {
             // Ensure we convert to string safely
             selectedDeviceId = deviceList[0]['d_id'].toString();
           });
           debugPrint("✅ Device ID Found: $selectedDeviceId");
        } else {
           debugPrint("⚠️ No devices found in response data.");
        }
      } else {
        debugPrint("Error fetching devices: ${response.statusCode}");
        // We do NOT call loadMockData here immediately to allow retries or other logic
      }
    } catch (e) {
      debugPrint("Exception fetching devices: $e");
    }
  }

  Future<void> _fetchLiveData() async {
    if (selectedDeviceId.isEmpty || selectedDeviceId.contains("Demo")) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/live-data/$selectedDeviceId'),
        headers: {
          'Cookie': widget.sessionCookie,
          'User-Agent': 'FlutterApp',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Handle common wrapper keys 'data' or root level
        List<dynamic> readings = [];
        if (jsonResponse is List) {
          readings = jsonResponse;
        } else if (jsonResponse['data'] is List) {
          readings = jsonResponse['data'];
        }

        if (readings.isNotEmpty) {
          final reading = readings[0];
          
          if (mounted) {
            setState(() {
              sensorData = {
                "air_temp": double.tryParse(reading['temp'].toString()) ?? 0.0,
                "humidity": double.tryParse(reading['humidity'].toString()) ?? 0.0,
                "leaf_wetness": reading['leafwetness']?.toString() ?? "Dry",
                "soil_temp": double.tryParse(reading['depth_temp'].toString()) ?? 0.0,
                "soil_moisture": double.tryParse(reading['surface_humidity'].toString()) ?? 0.0,
                "rainfall": double.tryParse(reading['rainfall'].toString()) ?? 0.0,
                "light_intensity": double.tryParse(reading['light_intensity'].toString()) ?? 0.0,
                "wind": double.tryParse(reading['wind_speed'].toString()) ?? 0.0,
                "pressure": double.tryParse(reading['pressure'].toString()) ?? 0.0,
                "depth_temp": double.tryParse(reading['depth_temp'].toString()) ?? 0.0,
                "depth_humidity": double.tryParse(reading['depth_humidity'].toString()) ?? 0.0,
                "surface_temp": double.tryParse(reading['surface_temp'].toString()) ?? 0.0,
                "surface_humidity": double.tryParse(reading['surface_humidity'].toString()) ?? 0.0,
              };
              isLoading = false;
            });
          }
        }
      } else {
        debugPrint("Error fetching live data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception fetching live data: $e");
    }
  }

  // --- New function to fetch historical data for graphs ---
  Future<void> _fetchHistoryData() async {
    if (selectedDeviceId.isEmpty || selectedDeviceId.contains("Demo")) return;

    try {
      // Assuming 'daily' range gives enough points for a 24h curve
      final response = await http.get(
        Uri.parse('$_baseUrl/devices/$selectedDeviceId/history?range=daily'),
        headers: {
          'Cookie': widget.sessionCookie,
          'User-Agent': 'FlutterApp',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        List<dynamic> readings = [];
        if (jsonResponse is List) {
          readings = jsonResponse;
        } else if (jsonResponse['data'] is List) {
          readings = jsonResponse['data'];
        }

        if (readings.isNotEmpty) {
          // Extract temperature readings for the chart
          // Take last 24 points or interpolate if fewer
          List<double> temps = readings.map<double>((r) => double.tryParse(r['temp'].toString()) ?? 0.0).toList();
          
          // Ensure we have data points, reverse if needed based on API order (usually newest first)
          if (temps.isNotEmpty) {
             // If API returns newest first, reverse for the graph (oldest -> newest)
             temps = temps.reversed.toList(); 
             
             if (mounted) {
               setState(() {
                 tempHistory = temps;
               });
             }
          }
        }
      }
    } catch (e) {
      debugPrint("Exception fetching history data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF166534), 
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        backgroundColor: const Color(0xFF166534),
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.bot, color: Colors.white, size: 28),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) return;
          setState(() => _selectedIndex = index);
          if (index == 4) { 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AlertsScreen()),
            ).then((_) => setState(() => _selectedIndex = 0));
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF166534),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: "Sensors"),
          BottomNavigationBarItem(icon: SizedBox(height: 24), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Alerts"),
        ],
      ),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCustomHeader(context),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF166534)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildSensorInfoBox(),
                            const SizedBox(height: 24),
                            
                            Text(
                              "Field Conditions",
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFieldConditionsGrid(),
                            const SizedBox(height: 80), 
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

  // --- Widgets (Header, Grid, Cards) ---

  Widget _buildSensorInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.radio, size: 18, color: Color(0xFF166534)),
              ),
              const SizedBox(width: 10),
              Text(
                "Sensor Device Information",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Device ID:", selectedDeviceId), // Dynamic ID
                    const SizedBox(height: 12),
                    _buildInfoRow("Last Seen:", "Just now"), 
                    const SizedBox(height: 12),
                    _buildInfoRow("Battery:", "85%"), 
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow("Status:", "Online"),
                    const SizedBox(height: 12),
                    _buildInfoRow("Location:", "Field A"),
                    const SizedBox(height: 12),
                    _buildInfoRow("Signal:", "Excellent"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF15803D)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.public, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Grid Sphere Pvt. Ltd.",
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "AgriTech",
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(sessionCookie: widget.sessionCookie),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFieldConditionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9, 
      children: [
        _ConditionCard(
          title: "Air Temp",
          value: "${sensorData?['air_temp']}°C",
          icon: LucideIcons.thermometer,
          iconBg: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32),
          // --- UPDATED: Pass dynamic historical data ---
          child: _MiniLineChart(color: const Color(0xFF2E7D32), dataPoints: tempHistory),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TemperatureDetailsScreen(sensorData: sensorData)),
            );
          },
        ),
        _ConditionCard(
          title: "Humidity",
          value: "${sensorData?['humidity']}%",
          icon: LucideIcons.droplets,
          iconBg: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF0288D1),
          // For humidity, we don't have history yet, passing empty list will default to smooth curve
          child: _MiniLineChart(color: const Color(0xFF0288D1), dataPoints: []),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HumidityDetailsScreen(sensorData: sensorData)),
            );
          },
        ),
        _ConditionCard(
          title: "Leaf",
          customContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Leaf Wetness", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF374151))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text("${sensorData?['leaf_wetness']}", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 24),
                ],
              )
            ],
          ),
          icon: LucideIcons.leaf,
          iconBg: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF15803D),
        ),
        _ConditionCard(
          title: "Soil Temp\n(10cm)",
          value: "${sensorData?['soil_temp']}°C",
          icon: Icons.device_thermostat, 
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
        ),
        _ConditionCard(
          title: "Soil\nMoisture",
          subtitle: "(avg)",
          value: "${sensorData?['soil_moisture']}% VWC",
          icon: LucideIcons.waves,
          iconBg: const Color(0xFFE0E7FF),
          iconColor: const Color(0xFF4F46E5),
        ),
        _ConditionCard(
          title: "Today's\nRainfall",
          subtitle: "Today",
          value: "${sensorData?['rainfall']} mm",
          icon: LucideIcons.cloudRain,
          iconBg: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0EA5E9),
        ),
        _ConditionCard(
          title: "Light\nIntensity",
          value: "${sensorData?['light_intensity']} lx",
          icon: LucideIcons.sun,
          iconBg: const Color(0xFFFFFDE7),
          iconColor: const Color(0xFFFBC02D),
        ),
        _ConditionCard(
          title: "Wind",
          value: "${sensorData?['wind']} km/h",
          icon: LucideIcons.wind,
          iconBg: const Color(0xFFE0F7FA),
          iconColor: const Color(0xFF0097A7),
        ),
        _ConditionCard(
          title: "Pressure",
          value: "${sensorData?['pressure']} hPa",
          icon: LucideIcons.gauge,
          iconBg: const Color(0xFFF3E5F5),
          iconColor: const Color(0xFF7B1FA2),
        ),
        _ConditionCard(
          title: "Depth Temp\n(10cm)",
          value: "${sensorData?['depth_temp']}°C",
          icon: Icons.device_thermostat, 
          iconBg: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32),
        ),
        _ConditionCard(
          title: "Depth Hum\n(10cm)",
          value: "${sensorData?['depth_humidity']}%",
          icon: LucideIcons.droplet, 
          iconBg: const Color(0xFFE1F5FE),
          iconColor: const Color(0xFF0288D1),
        ),
        _ConditionCard(
          title: "Surf Temp",
          value: "${sensorData?['surface_temp']}°C",
          icon: Icons.thermostat,
          iconBg: const Color(0xFFFFEBEE),
          iconColor: const Color(0xFFD32F2F),
        ),
        _ConditionCard(
          title: "Surf Hum",
          value: "${sensorData?['surface_humidity']}%",
          icon: LucideIcons.waves,
          iconBg: const Color(0xFFEFEBE9),
          iconColor: const Color(0xFF5D4037),
        ),
      ],
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final String title;
  final String? value;
  final String? subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Widget? child;
  final Widget? customContent;
  final VoidCallback? onTap;

  const _ConditionCard({
    required this.title,
    this.value,
    this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.child,
    this.customContent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (customContent != null)
              Expanded(child: customContent!)
            else ...[
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
                ),
              const SizedBox(height: 4),
              Text(
                value ?? "--",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
            if (child != null) ...[
              const Spacer(),
              child!,
            ]
          ],
        ),
      ),
    );
  }
}

class _MiniLineChart extends StatelessWidget {
  final Color color;
  final List<double> dataPoints; // Receive actual data
  const _MiniLineChart({required this.color, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(color, dataPoints),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color color;
  final List<double> dataPoints;
  _ChartPainter(this.color, this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    if (dataPoints.isEmpty) {
        // Fallback smooth curve if no data yet
        path.moveTo(0, size.height);
        path.quadraticBezierTo(size.width * 0.25, size.height * 0.7, size.width * 0.5, size.height * 0.5);
        path.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.2);
    } else {
        // Normalize points to fit the box
        double minVal = dataPoints.reduce(min);
        double maxVal = dataPoints.reduce(max);
        double range = maxVal - minVal;
        if (range == 0) range = 1; // Prevent division by zero

        double stepX = size.width / (dataPoints.length - 1);
        
        for (int i = 0; i < dataPoints.length; i++) {
            double normalizedY = 1.0 - ((dataPoints[i] - minVal) / range);
            // Add some padding so line doesn't hit exact edges (0.1 to 0.9)
            double y = size.height * (0.1 + (normalizedY * 0.8));
            
            if (i == 0) {
                path.moveTo(0, y);
            } else {
                path.lineTo(i * stepX, y);
            }
        }
    }

    canvas.drawShadow(path, color.withOpacity(0.2), 2.0, true);
    
    canvas.drawPath(path, paint);
    
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
      
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
    );
    
    canvas.drawPath(fillPath, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Repaint when data changes
}