import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- Temporary Credentials ---
  final String _validId = "admin";
  final String _validPassword = "password";

  void _handleLogin() async {
    // Dismiss keyboard when login starts
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate network request
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

      if (_idController.text == _validId &&
          _passwordController.text == _validPassword) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid ID or Password',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector allows tapping outside to close keyboard
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF166534), // Dark Green Brand Color
        resizeToAvoidBottomInset: true, // Ensures keyboard pushes content up
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 64,
                      height: 64,
                      // If the image fails to load (missing file), show the Icon instead
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.public, // Represents 'Grid Sphere'
                          size: 64,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Welcome Back",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Sign in to access your farm data",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Login",
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

                          // ID Input
                          TextFormField(
                            controller: _idController,
                            keyboardType: TextInputType
                                .emailAddress, // Hints keyboard type
                            textInputAction:
                                TextInputAction.next, // Shows "Next" button
                            decoration: InputDecoration(
                              labelText: "User ID",
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF166534), width: 2),
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? "Please enter your User ID"
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction
                                .done, // Shows "Done/Check" button
                            onFieldSubmitted: (_) =>
                                _handleLogin(), // Login on Enter
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.remove_red_eye
                                      : Icons.remove_red_eye_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF166534), width: 2),
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? "Please enter your password"
                                : null,
                          ),
                          const SizedBox(height: 30),

                          // Login Button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF166534),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Sign In",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
      ),
    );
  }
}
