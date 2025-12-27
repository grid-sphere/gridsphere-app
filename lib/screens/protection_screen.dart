import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'chat_screen.dart';
import 'alerts_screen.dart';
import 'dashboard_screen.dart';
import 'soil_screen.dart';

class GoogleFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

class ProtectionScreen extends StatefulWidget {
  final String sessionCookie;
  final String deviceId;

  const ProtectionScreen({
    super.key, 
    required this.sessionCookie,
    this.deviceId = "", 
  });

  @override
  State<ProtectionScreen> createState() => _ProtectionScreenState();
}

class _ProtectionScreenState extends State<ProtectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1; 
  final String _baseUrl = "https://gridsphere.in/station/api";

  // Data for Overall Display
  String fungusRisk = "Low";
  double fungusChance = 0.0;
  String pestRisk = "Low";
  double pestChance = 0.0;
  bool _isLoading = true;

  // New state variables to support SoilScreen parameters
  Map<String, dynamic>? sensorData;
  List<dynamic> _devices = [];
  String _tempDeviceId = "";

  final List<String> _fungiNames = [
    "Apple Scab",
    "Alternaria Blotch",
    "Marssonina Blotch",
    "Powdery Mildew",
    "Cedar-Apple Rust",
    "Black Rot",
    "Bitter Rot"
  ];
  Map<String, dynamic> _fungiRisks = {}; 

  final List<String> _pestNames = [
    "Codling Moth",
    "Aphids",
    "Apple Maggot",
    "Spider Mites",
    "San Jose Scale"
  ];
  Map<String, dynamic> _pestRisks = {}; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLiveAndCalculateRisks();
  }

  Future<void> _fetchLiveAndCalculateRisks() async {
    String targetDeviceId = widget.deviceId;
    
    // Ensure we have the device list for lat/lon lookups
    await _fetchDefaultDeviceId();
    
    if (targetDeviceId.isEmpty) {
        targetDeviceId = _tempDeviceId;
    }

    if (targetDeviceId.isEmpty || targetDeviceId.contains("Demo")) {
        _generateMockData();
        return; 
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/live-data/$targetDeviceId'),
        headers: {
          'Cookie': widget.sessionCookie,
          'User-Agent': 'FlutterApp',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> readings = [];
        if (jsonResponse is List) readings = jsonResponse;
        else if (jsonResponse['data'] is List) readings = jsonResponse['data'];

        if (readings.isNotEmpty) {
          final reading = readings[0];
          
          // Store raw sensor data to pass to other screens
          sensorData = Map<String, dynamic>.from(reading);
          
          double temp = double.tryParse(reading['temp'].toString()) ?? 0.0;
          double humidity = double.tryParse(reading['humidity'].toString()) ?? 0.0;
          double wetnessHours = await _calculateWetnessDuration(targetDeviceId);

          _calculateRisks(temp, wetnessHours, humidity);
        } else {
           _generateMockData(); 
        }
      } else {
        _generateMockData(); 
      }
    } catch (e) {
      debugPrint("Error fetching live protection data: $e");
      _generateMockData();
    }
  }

  Future<double> _calculateWetnessDuration(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/devices/$id/history?range=daily'), 
        headers: {
          'Cookie': widget.sessionCookie,
          'User-Agent': 'FlutterApp',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> list = (jsonResponse is List) ? jsonResponse : (jsonResponse['data'] ?? []);

        int wetCount = 0;
        for (var r in list) {
           String status = r['leafwetness']?.toString().toLowerCase() ?? "dry";
           if (status == "wet" || status == "1" || (double.tryParse(status) ?? 0) > 0) {
             wetCount++;
           }
        }
        return wetCount.toDouble();
      }
    } catch (e) {
      return 0.0;
    }
    return 0.0;
  }

  Future<void> _fetchDefaultDeviceId() async {
     try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getDevices'),
        headers: {'Cookie': widget.sessionCookie, 'User-Agent': 'FlutterApp'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List list = (data is List) ? data : (data['data'] ?? []);
        if (list.isNotEmpty) {
          if (mounted) {
            setState(() {
              _devices = list;
              _tempDeviceId = list[0]['d_id'].toString();
            });
          }
        }
      }
     } catch (_) {}
  }

  void _calculateRisks(double temp, double wetnessHours, double humidity) {
    if (!mounted) return;

    Map<String, dynamic> scab = _calculateAppleScab(temp, wetnessHours);
    Map<String, dynamic> alternaria = _calculateAlternaria(temp, wetnessHours);
    Map<String, dynamic> marssonina = _calculateMarssonina(temp, wetnessHours);
    Map<String, dynamic> mildew = _calculatePowderyMildew(temp, humidity);
    Map<String, dynamic> cedar = _calculateCedarRust(temp, wetnessHours);
    Map<String, dynamic> blackRot = _calculateBlackRot(temp, wetnessHours);
    Map<String, dynamic> bitterRot = _calculateBitterRot(temp, wetnessHours);

    double degreeDays = (temp > 10) ? (temp - 10) * 15 : 50; 

    Map<String, dynamic> codlingMoth = _getCodlingMothRisk(degreeDays);
    Map<String, dynamic> aphids = _getAphidRisk(temp, humidity);
    Map<String, dynamic> appleMaggot = _getAppleMaggotRisk(degreeDays);
    Map<String, dynamic> spiderMites = _getSpiderMiteRisk(temp, humidity);
    Map<String, dynamic> sanJoseScale = _getSanJoseScaleRisk(degreeDays);

    setState(() {
      _fungiRisks = {
        "Apple Scab": scab,
        "Alternaria Blotch": alternaria,
        "Marssonina Blotch": marssonina,
        "Powdery Mildew": mildew,
        "Cedar-Apple Rust": cedar,
        "Black Rot": blackRot,
        "Bitter Rot": bitterRot,
      };

      List<double> allFungusRisks = _fungiRisks.values.map((e) => (e['value'] as num).toDouble()).toList();
      fungusChance = allFungusRisks.reduce(max);
      fungusRisk = _getRiskLabel(fungusChance);

      _pestRisks = {
        "Codling Moth": codlingMoth,
        "Aphids": aphids,
        "Apple Maggot": appleMaggot,
        "Spider Mites": spiderMites,
        "San Jose Scale": sanJoseScale,
      };

      List<double> allPestRisks = _pestRisks.values.map((e) => (e['value'] as num).toDouble()).toList();
      pestChance = allPestRisks.reduce(max);
      pestRisk = _getRiskLabel(pestChance);

      _isLoading = false;
    });
  }

  void _generateMockData() {
    if (!mounted) return;
    final random = Random();
    double temp = 15.0 + random.nextDouble() * 15;
    double wetnessHours = random.nextDouble() * 24;
    double humidity = 50 + random.nextDouble() * 50;
    _calculateRisks(temp, wetnessHours, humidity);
  }

  Map<String, dynamic> _calculateAppleScab(double temp, double wetnessHours) {
    if (temp < 6) return {'value': 0, 'status': "Low"}; 
    double? requiredHours;
    if (temp >= 18 && temp <= 24) { requiredHours = 9; }
    else if (temp >= 17 && temp < 18) { requiredHours = 10; }
    else if (temp >= 16 && temp < 17) { requiredHours = 11; }
    else if (temp >= 15 && temp < 16) { requiredHours = 12; }
    else if (temp >= 13 && temp <= 14) { requiredHours = 14; }
    else if (temp >= 12 && temp < 13) { requiredHours = 15; }
    else if (temp >= 10 && temp <= 11) { requiredHours = 20; }
    if (requiredHours == null) return {'value': 0, 'status': "Low"};
    double risk = min((wetnessHours / requiredHours) * 100, 100);
    return {'value': risk.round(), 'status': _getRiskLabel(risk)};
  }

  Map<String, dynamic> _calculateAlternaria(double temp, double wetnessHours) {
    if (temp >= 25 && temp <= 30 && wetnessHours >= 5.5) return {'value': 80, 'status': "High"};
    if (temp >= 20 && temp <= 32 && wetnessHours >= 4) return {'value': 50, 'status': "Medium"};
    return {'value': 10, 'status': "Low"};
  }

  Map<String, dynamic> _calculateMarssonina(double temp, double wetnessHours) {
    if (temp >= 20 && temp <= 25 && wetnessHours >= 24) return {'value': 90, 'status': "High"};
    if (temp >= 16 && temp <= 28 && wetnessHours >= 10) return {'value': 60, 'status': "Medium"};
    return {'value': 10, 'status': "Low"};
  }

  Map<String, dynamic> _calculatePowderyMildew(double temp, double humidity) {
    if (temp < 10 || temp > 25 || humidity < 70) return {'value': 10, 'status': "Low"};
    bool optimal = (temp >= 19 && temp <= 22 && humidity > 75);
    int riskValue = optimal ? 90 : 60;
    return {'value': riskValue, 'status': _getRiskLabel(riskValue.toDouble())};
  }

  Map<String, dynamic> _calculateCedarRust(double temp, double wetnessHours) {
    if (temp >= 13 && temp <= 24 && wetnessHours >= 4) return {'value': 75, 'status': "High"};
    if (temp >= 10 && temp <= 26 && wetnessHours >= 2) return {'value': 50, 'status': "Medium"};
    return {'value': 10, 'status': "Low"};
  }

  Map<String, dynamic> _calculateBlackRot(double temp, double wetnessHours) {
    if (temp < 20 || temp > 35 || wetnessHours < 4) return {'value': 10, 'status': "Low"};
    bool optimal = (temp >= 26 && temp <= 32 && wetnessHours >= 6);
    int riskValue = optimal ? 85 : 60;
    return {'value': riskValue, 'status': _getRiskLabel(riskValue.toDouble())};
  }

  Map<String, dynamic> _calculateBitterRot(double temp, double wetnessHours) {
    if (temp >= 26 && temp <= 32 && wetnessHours >= 5) return {'value': 80, 'status': "High"};
    if (temp >= 20 && temp <= 35 && wetnessHours >= 3) return {'value': 50, 'status': "Medium"};
    return {'value': 10, 'status': "Low"};
  }

  Map<String, dynamic> _getCodlingMothRisk(double degreeDays) {
    if (degreeDays > 250) return {'value': 85, 'status': "High"};
    if (degreeDays > 50) return {'value': 40, 'status': "Medium"};
    return {'value': 10, 'status': "Low"};
  }

  Map<String, dynamic> _getAphidRisk(double temp, double humidity) {
    if (temp > 18 && temp < 25 && humidity < 70) return {'value': 90, 'status': "High"};
    if (temp > 15 && temp < 28) return {'value': 50, 'status': "Medium"};
    return {'value': 10, 'status': "Low"};
  }

  Map<String, dynamic> _getAppleMaggotRisk(double degreeDays) {
    if (degreeDays > 900) return {'value': 80, 'status': "High"};
    if (degreeDays > 700) return {'value': 40, 'status': "Medium"};
    return {'value': 10, 'status': "Low"};
  }

  Map<String, dynamic> _getSpiderMiteRisk(double temp, double humidity) {
    if (temp > 29 && humidity < 60) return {'value': 95, 'status': "High"};
    if (temp > 25 && humidity < 70) return {'value': 60, 'status': "Medium"};
    return {'value': 10, 'status': "Low"};
  }

  Map<String, dynamic> _getSanJoseScaleRisk(double degreeDays) {
    if (degreeDays > 400 && degreeDays < 600) return {'value': 90, 'status': "High"};
    if (degreeDays > 250) return {'value': 30, 'status': "Medium"};
    return {'value': 10, 'status': "Low"};
  }

  String _getRiskLabel(double chance) {
    if (chance < 30) return "Low";
    if (chance < 70) return "Medium";
    return "High";
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case "Low": case "No Risk": return const Color(0xFF22C55E); 
      case "Medium": return const Color(0xFFF59E0B); 
      case "High": return const Color(0xFFEF4444); 
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF166534),
      appBar: AppBar(
        backgroundColor: const Color(0xFF166534),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Field Protection",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF166534), 
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
              dividerColor: Colors.transparent, 
              tabs: const [
                Tab(text: "Fungal Risk"),
                Tab(text: "Pest Activity"),
              ],
            ),
          ),
        ),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen(deviceId: widget.deviceId)),
          );
        },
        backgroundColor: const Color(0xFF166534),
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.bot, color: Colors.white, size: 28),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF166534),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        onTap: (index) {
          if (index == 2 || index == _selectedIndex) return; 
          
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen(sessionCookie: widget.sessionCookie)),
              (route) => false,
            );
          } else if (index == 3) {
            // Updated Soil Tab Navigation with lat/lon and sensor data
            double lat = 0.0;
            double lon = 0.0;
            String targetId = widget.deviceId.isEmpty ? _tempDeviceId : widget.deviceId;
            
            try {
              final device = _devices.firstWhere(
                (d) => d['d_id'].toString() == targetId,
                orElse: () => <String, dynamic>{},
              );
              if (device.isNotEmpty) {
                 lat = double.tryParse(device['latitude']?.toString() ?? "0.0") ?? 0.0;
                 lon = double.tryParse(device['longitude']?.toString() ?? "0.0") ?? 0.0;
              }
            } catch (e) {
              debugPrint("Error parsing lat/lon in Protection: $e");
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SoilScreen(
                sessionCookie: widget.sessionCookie,
                deviceId: targetId,
                sensorData: sensorData,
                latitude: lat,
                longitude: lon,
              )),
            ).then((_) { if(mounted) setState(() => _selectedIndex = 1); });
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlertsScreen(
                sessionCookie: widget.sessionCookie,
                deviceId: widget.deviceId,
              )),
            ).then((_) { if(mounted) setState(() => _selectedIndex = 1); });
          } else {
             setState(() => _selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.shieldCheck), label: "Protection"),
          BottomNavigationBarItem(icon: SizedBox(height: 24), label: ""),
          BottomNavigationBarItem(icon: Icon(LucideIcons.layers), label: "Soil"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Alerts"),
        ],
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF166534)))
            : TabBarView(
            controller: _tabController,
            children: [
              _buildFungusContent(), 
              _buildPestContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFungusContent() {
    Color riskColor = _getRiskColor(fungusRisk);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildSummaryCard("Fungal Infection", fungusRisk, fungusChance, riskColor, LucideIcons.sprout),
          const SizedBox(height: 20),
          _buildDetailList(_fungiNames, _fungiRisks),
          const SizedBox(height: 24),
          _buildInsightCard("High humidity levels observed. Conditions are favorable for Apple Scab germination."),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPestContent() {
    Color riskColor = _getRiskColor(pestRisk);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildSummaryCard("Pest Activity", pestRisk, pestChance, riskColor, LucideIcons.bug),
          const SizedBox(height: 20),
          _buildDetailList(_pestNames, _pestRisks),
          const SizedBox(height: 24),
          _buildInsightCard("Warm temperatures favor aphid reproduction. Inspect undersides of leaves in Zone B."),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String risk, double chance, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("OVERALL RISK", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text(label, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: chance / 100,
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${chance.toStringAsFixed(0)}%", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                  Text("Probability", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Text("$risk Risk", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailList(List<String> names, Map<String, dynamic> risks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Detailed Breakdown", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
          const SizedBox(height: 16),
          ...names.map((name) {
            var r = risks[name] ?? {'value': 0, 'status': "Low"};
            double val = (r['value'] as num).toDouble();
            Color c = _getRiskColor(r['status']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
                      Text("${val.toStringAsFixed(0)}%", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: c)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                      FractionallySizedBox(
                        widthFactor: val / 100,
                        child: Container(height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(LucideIcons.bot, size: 20, color: Color(0xFF2563EB))),
              const SizedBox(width: 12),
              Text("AI Assistant Insight", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF))),
            ],
          ),
          const SizedBox(height: 12),
          Text(text, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E3A8A), height: 1.5)),
        ],
      ),
    );
  }
}