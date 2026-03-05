import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login_screen.dart';
import '../session_manager/session_manager.dart';

// Fallback GoogleFonts class
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

class ProfileScreen extends StatefulWidget {
  final String sessionCookie;

  const ProfileScreen({super.key, required this.sessionCookie});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _baseUrl = "https://gridsphere.in/station/api";
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  String _selectedRole = SessionManager().role;
  String? _activeDeviceId; // Added to hold the device ID for API calls

  final Map<String, String> _roleLabels = {
    'agriculture': 'Agriculture',
    'cement': 'Cement',
    'chemical': 'Chemical',
  };

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  String _mapValueToRole(int val) {
    if (val == 1) return 'agriculture';
    if (val == 2) return 'cement';
    return 'chemical'; // 0 or others
  }

  int _mapRoleToValue(String role) {
    if (role == 'agriculture') return 1;
    if (role == 'cement') return 2;
    return 0; // chemical/others
  }

  Future<void> _fetchUserData() async {
    try {
      // 1. Fetch Session info
      final sessionResponse = await http.get(
        Uri.parse('$_baseUrl/checkSession'),
        headers: {
          'Cookie': widget.sessionCookie,
          'User-Agent': 'FlutterApp',
        },
      );

      String userId = "Loading...";
      String username = "Farmer";
      String email = "--";
      String mobile = "--";
      String address = "India";

      if (sessionResponse.statusCode == 200) {
        final sessionData = jsonDecode(sessionResponse.body);
        if (sessionData['user_id'] != null) {
          userId = sessionData['user_id'].toString();
        }
        // Initial name from session if available
        if (sessionData['username'] != null) {
          username = sessionData['username'].toString();
        }
        if (sessionData['email'] != null) {
          email = sessionData['email'].toString();
        }
        if (sessionData['phone'] != null) {
          mobile = sessionData['phone'].toString();
        } else if (sessionData['mobile'] != null) {
          mobile = sessionData['mobile'].toString();
        }

        List<String> addrParts = [];
        if (sessionData['city'] != null) addrParts.add(sessionData['city']);
        if (sessionData['state'] != null) addrParts.add(sessionData['state']);

        if (addrParts.isNotEmpty) {
          address = addrParts.join(", ");
        } else if (sessionData['address'] != null) {
          address = sessionData['address'].toString();
        }

        if (userId == "Loading...") userId = "admin";
      }

      // 2. Fetch Devices (Used for Address, Farmer Name fallback, and Device ID)
      final devicesResponse = await http.get(
        Uri.parse('$_baseUrl/getDevices'),
        headers: {
          'Cookie': widget.sessionCookie,
          'User-Agent': 'FlutterApp',
        },
      );

      int deviceCount = 0;
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

        deviceCount = deviceList.length;
        if (deviceList.isNotEmpty) {
          var firstDevice = deviceList[0];

          // Store device ID for the new Industry API
          _activeDeviceId = firstDevice['d_id']?.toString();

          // Use 'farm_name' from the device API for the farmer's display name
          String farmNameFromApi = firstDevice['farm_name']?.toString() ?? "";
          if (farmNameFromApi.isNotEmpty) {
            username = farmNameFromApi;
          }

          // Fallback address from device if session address is generic
          if (address == "India" || address.isEmpty) {
            address = firstDevice['address']?.toString() ??
                firstDevice['location']?.toString() ??
                "India";
          }
        }
      }

      // 3. Fetch the current Industry Type from the new backend API (integer mapping)
      if (_activeDeviceId != null) {
        try {
          final industryResponse = await http.get(
            Uri.parse('$_baseUrl/devices/$_activeDeviceId/industry'),
            headers: {
              'Cookie': widget.sessionCookie,
              'User-Agent': 'FlutterApp',
            },
          );

          if (industryResponse.statusCode == 200) {
            final indData = jsonDecode(industryResponse.body);
            if (indData['status'] == true && indData['data'] != null) {
              int indValue = int.tryParse(
                      indData['data']['industry_value']?.toString() ?? '1') ??
                  1;
              String fetchedRole = _mapValueToRole(indValue);

              if (_roleLabels.containsKey(fetchedRole)) {
                _selectedRole = fetchedRole;
                SessionManager().setRole(fetchedRole);
                SessionManager().setIndustryValue(indValue);
                await SessionManager()
                    .saveRole(fetchedRole, industryValue: indValue);
              }
            }
          }
        } catch (e) {
          debugPrint("Error fetching industry type: $e");
        }
      }

      if (mounted) {
        setState(() {
          userData = {
            "name": username,
            "id": userId,
            "email": email,
            "mobile": mobile,
            "address": address,
            "role": "Manager",
            "devices": deviceCount,
          };
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) {
        setState(() {
          userData = {
            "name": "User",
            "id": "Unknown",
            "email": "--",
            "mobile": "--",
            "address": "Unknown",
            "role": "Manager",
            "devices": 0,
          };
          isLoading = false;
        });
      }
    }
  }

  // --- POST Industry Type Update to Backend as Integer ---
  Future<bool> _updateIndustryTypeOnBackend(String newRole) async {
    if (_activeDeviceId == null) return false;

    try {
      // 1. Fetch CSRF token for secure POST
      final csrfResponse = await http.get(
        Uri.parse('$_baseUrl/getCSRF'),
        headers: {'User-Agent': 'FlutterApp', 'Cookie': widget.sessionCookie},
      );

      String csrfName = '';
      String csrfValue = '';
      if (csrfResponse.statusCode == 200) {
        final csrfData = jsonDecode(csrfResponse.body);
        csrfName = csrfData['csrf_name'] ?? '';
        csrfValue = csrfData['csrf_token'] ?? '';
      }

      int newMappedValue = _mapRoleToValue(newRole);

      // 2. Prepare POST Body (Sending as strictly defined values (0, 1, 2))
      Map<String, String> bodyData = {
        'industry_type': newMappedValue.toString(),
      };
      if (csrfName.isNotEmpty && csrfValue.isNotEmpty) {
        bodyData[csrfName] = csrfValue;
      }

      // 3. Make the POST request
      final response = await http.post(
        Uri.parse('$_baseUrl/devices/$_activeDeviceId/industry'),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Cookie": widget.sessionCookie,
          "User-Agent": "FlutterApp",
        },
        body: bodyData,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
            "Failed to update industry. Status: ${response.statusCode}, Body: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error updating industry type: $e");
      return false;
    }
  }

  Future<void> _handleLogout() async {
    try {
      final csrfResponse = await http.get(
        Uri.parse('$_baseUrl/getCSRF'),
        headers: {'User-Agent': 'FlutterApp'},
      );

      if (csrfResponse.statusCode == 200) {
        final csrfData = jsonDecode(csrfResponse.body);
        final String csrfName = csrfData['csrf_name'];
        final String csrfValue = csrfData['csrf_token'];

        await http.post(Uri.parse('$_baseUrl/logout'), headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Cookie": widget.sessionCookie,
          "User-Agent": "FlutterApp",
        }, body: {
          csrfName: csrfValue,
        });
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
    SessionManager().clearSession();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF166534), // Dark Green Header
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                const SizedBox(height: 20),
                // Profile Image Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6C0B3), // Beige/Skin tone
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person,
                            size: 60, color: Color(0xFF5D4037)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData["name"] ?? "User",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Grid Sphere Pvt. Ltd.",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Details Card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9), // Light grey background
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildInfoTile("User Name",
                              userData["name"] ?? "User", LucideIcons.user),
                          const SizedBox(height: 16),
                          _buildInfoTile("Email", userData["email"] ?? "--",
                              LucideIcons.mail),
                          const SizedBox(height: 16),
                          _buildInfoTile("Mobile Number",
                              userData["mobile"] ?? "--", LucideIcons.phone),
                          const SizedBox(height: 16),
                          _buildInfoTile("Address", userData["address"] ?? "--",
                              LucideIcons.mapPin),
                          const SizedBox(height: 16),
                          _buildInfoTile("User ID", userData["id"] ?? "--",
                              LucideIcons.badgeInfo),
                          const SizedBox(height: 16),
                          _buildInfoTile(
                              "Active Devices",
                              "${userData["devices"] ?? 0} Sensors",
                              LucideIcons.radio),

                          const SizedBox(height: 16),
                          _buildRoleDropdown(), // Updated Dropdown Widget

                          const SizedBox(height: 40),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red.shade700,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.red.shade100),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.logOut, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Log Out",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // --- Helper to map Role to Icon ---
  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'agriculture':
        return LucideIcons.sprout;
      case 'cement':
        return LucideIcons.factory;
      case 'chemical':
        return LucideIcons.flaskConical;
      default:
        return LucideIcons.briefcase;
    }
  }

  // --- Show Beautiful Bottom Sheet ---
  void _showIndustrySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Select Industry",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            ..._roleLabels.entries.map((entry) {
              final isSelected = _selectedRole == entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () async {
                    // Close the bottom sheet immediately using sheetContext
                    Navigator.pop(sheetContext);

                    // We can now safely use the main 'context' from State
                    if (_activeDeviceId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No device active to update industry."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Show loader in the background UI
                    setState(() => isLoading = true);

                    // Call backend API
                    bool success =
                        await _updateIndustryTypeOnBackend(entry.key);

                    if (!mounted) return;

                    if (success) {
                      setState(() {
                        _selectedRole = entry.key;
                      });
                      int intValue = _mapRoleToValue(entry.key);
                      SessionManager().setIndustryValue(intValue);
                      await SessionManager()
                          .saveRole(entry.key, industryValue: intValue);

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Industry type updated successfully!"),
                          backgroundColor: Color(0xFF166534),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to update industry type."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }

                    // Remove loader
                    setState(() => isLoading = false);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF166534).withOpacity(0.05)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF166534)
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF166534)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getRoleIcon(entry.key),
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(LucideIcons.checkCircle,
                              color: Color(0xFF166534), size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // --- Trigger Widget ---
  Widget _buildRoleDropdown() {
    return GestureDetector(
      onTap: _showIndustrySelector,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF166534).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getRoleIcon(_selectedRole),
                  color: const Color(0xFF166534), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Industry Type",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _roleLabels[_selectedRole] ?? "Select Industry",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronDown, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF166534).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF166534), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
