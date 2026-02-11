import 'package:flutter/material.dart';

class AlertSettingsScreen extends StatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  static const Color primaryGreen = Color(0xFF166534);

  final List<Map<String, dynamic>> sensors = [
    {"name": "Temperature", "icon": Icons.thermostat},
    {"name": "Humidity", "icon": Icons.water_drop},
    {"name": "Rainfall", "icon": Icons.cloud},
    {"name": "Light Intensity", "icon": Icons.wb_sunny},
    {"name": "Pressure", "icon": Icons.speed},
    {"name": "Wind Speed", "icon": Icons.air},
    {"name": "PM 2.5", "icon": Icons.blur_on},
    {"name": "CO2", "icon": Icons.cloud_queue},
    {"name": "TVOC", "icon": Icons.science},
    {"name": "AQI", "icon": Icons.cloud},
  ];

  Map<String, bool> toggleStates = {};

  @override
  void initState() {
    super.initState();
    for (var sensor in sensors) {
      toggleStates[sensor["name"]] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Alert Configuration",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Set Thresholds",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              /// Sensor List
              Expanded(
                child: ListView.separated(
                  itemCount: sensors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final sensor = sensors[index];
                    final isOn = toggleStates[sensor["name"]] ?? false;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isOn ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          /// Icon Box
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: isOn
                                  ? Colors.white.withOpacity(0.2)
                                  : primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              sensor["icon"],
                              color: isOn ? Colors.white : primaryGreen,
                            ),
                          ),

                          const SizedBox(width: 15),

                          /// Title
                          Expanded(
                            child: Text(
                              sensor["name"],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isOn ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),

                          /// Switch
                          Switch(
                            value: isOn,
                            activeColor: primaryGreen,           // Thumb ON
                            activeTrackColor: Colors.white70,    // Track ON
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.grey.shade300,
                            onChanged: (value) {
                              setState(() {
                                toggleStates[sensor["name"]] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
