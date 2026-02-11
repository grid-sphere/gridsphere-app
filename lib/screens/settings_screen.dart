import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryGreen = Color(0xFF166534);

  String? selectedIndustry;

  final List<Map<String, dynamic>> industries = [
    {"name": "Agriculture", "icon": Icons.eco},
    {"name": "Chemical", "icon": Icons.science},
    {"name": "Cement", "icon": Icons.factory},
    {"name": "Oil and Gas", "icon": Icons.local_fire_department},
    {"name": "Pharmaceutical", "icon": Icons.medical_services},
    {"name": "Power Plant / Energy", "icon": Icons.bolt},
    {"name": "Smart City", "icon": Icons.location_city},
    {"name": "Manufacturing", "icon": Icons.precision_manufacturing},
  ];

  @override
  void initState() {
    super.initState();
    _loadIndustry();
  }

  Future<void> _loadIndustry() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndustry = prefs.getString('selected_industry');
    });
  }

  Future<void> _saveIndustry(String industry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_industry', industry);
    setState(() {
      selectedIndustry = industry;
    });
  }

  void _openIndustrySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Industry",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: industries.length,
                  itemBuilder: (context, index) {
                    final industry = industries[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          industry["icon"],
                          color: primaryGreen,
                        ),
                      ),
                      title: Text(
                        industry["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: selectedIndustry == industry["name"]
                          ? const Icon(
                        Icons.check_circle,
                        color: primaryGreen,
                      )
                          : null,
                      onTap: () async {
                        await _saveIndustry(industry["name"]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.white),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 24),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "UNIT CONFIGURATION",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _settingsCard(
                    icon: Icons.dashboard,
                    title: "Dashboard Layout",
                    subtitle: "Customize visible sensors and order",
                  ),

                  const SizedBox(height: 15),

                  _settingsCard(
                    icon: Icons.notifications,
                    title: "Alert Settings",
                    subtitle: "Set thresholds for notifications",
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Center(
                child: InkWell(
                  onTap: _openIndustrySheet,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            size: 20,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            selectedIndustry == null
                                ? "Current Industry: Nothing Selected"
                                : "Current Industry: $selectedIndustry",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _settingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    const Color primaryGreen = Color(0xFF166534);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryGreen),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
