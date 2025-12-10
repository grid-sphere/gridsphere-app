import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'login_screen.dart'; // To navigate back to login on logout

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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    // Navigate back to Login Screen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
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
      body: Column(
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
                  child: const Icon(Icons.person, size: 60, color: Color(0xFF5D4037)),
                ),
                const SizedBox(height: 16),
                Text(
                  "Farm Admin",
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildInfoTile("User ID", "admin", LucideIcons.user),
                    const SizedBox(height: 16),
                    _buildInfoTile("Role", "Orchard Manager", LucideIcons.badgeCheck),
                    const SizedBox(height: 16),
                    _buildInfoTile("Email", "admin@gridsphere.in", LucideIcons.mail),
                    const SizedBox(height: 16),
                    _buildInfoTile("Phone", "+91 98765 43210", LucideIcons.phone),
                    const SizedBox(height: 16),
                    _buildInfoTile("Farm Location", "Himachal Pradesh, India", LucideIcons.mapPin),
                    
                    const SizedBox(height: 40),
                    
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleLogout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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