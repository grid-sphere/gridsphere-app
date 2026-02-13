import 'package:flutter/material.dart';

const Color brandGreen = Color(0xFF166534);

class DashboardLayoutScreen extends StatefulWidget {
  const DashboardLayoutScreen({super.key});

  @override
  State<DashboardLayoutScreen> createState() =>
      _DashboardLayoutScreenState();
}

class _DashboardLayoutScreenState
    extends State<DashboardLayoutScreen> {

  final List<_ParameterItem> parameters = [
    _ParameterItem("Temperature", Icons.thermostat),
    _ParameterItem("Humidity", Icons.water_drop),
    _ParameterItem("Rainfall", Icons.grain),
    _ParameterItem("Light Intensity", Icons.wb_sunny),
    _ParameterItem("Pressure", Icons.speed),
    _ParameterItem("Wind Speed", Icons.air),
    _ParameterItem("PM 2.5", Icons.blur_on),
    _ParameterItem("CO2", Icons.cloud),
    _ParameterItem("TVOC", Icons.science),
    _ParameterItem("AQI", Icons.cloud_queue),
  ];

  final Map<String, bool> toggleStates = {};

  @override
  void initState() {
    super.initState();
    for (var item in parameters) {
      toggleStates[item.title] = false; // all OFF initially
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandGreen,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Dashboard Layout",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// White Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Visible Parameters",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: ListView.separated(
                        itemCount: parameters.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = parameters[index];
                          return _parameterCard(item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _parameterCard(_ParameterItem item) {
    final isOn = toggleStates[item.title] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOn ? brandGreen : Colors.white,
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
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: isOn
                  ? Colors.white.withOpacity(0.2)
                  : brandGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.icon,
              color: isOn ? Colors.white : brandGreen,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          /// Title
          Expanded(
            child: Text(
              item.title,
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
            activeColor: brandGreen,           // thumb
            activeTrackColor: Colors.white70,  // track
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: (value) {
              setState(() {
                toggleStates[item.title] = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _ParameterItem {
  final String title;
  final IconData icon;

  _ParameterItem(this.title, this.icon);
}
