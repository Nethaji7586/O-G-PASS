import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'staff_dashboard.dart';
import 'student_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _obscureText = true;

  // --- Login Function with SharedPreferences ---
  void handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final data = await AuthService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid login credentials")),
      );
      return;
    }

    final String role = data['role'];
    final String name = data['name'];
    final String token = data['token'];

    // ✅ Save token & user info for persistent login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_role', role);
    await prefs.setString('user_name', name);

    // Navigate to appropriate dashboard
    if (role == "staff") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StaffDashboard(userName: name, token: token)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StudentDashboard(userName: name, token: token)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Circles
          Positioned(
            top: -100,
            right: -50,
            child: _buildCircle(size.width * 0.7, Colors.blue.shade300.withOpacity(0.5)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildCircle(size.width * 0.6, Colors.indigo.shade200.withOpacity(0.4)),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LOGO ---
                    Container(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Transform.scale(
                            scale: 1.2,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.school_rounded, size: 40, color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "SVGI-GOBI",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A237E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      "Welcome back, please login to continue",
                      style: TextStyle(color: Colors.black45, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // --- Input Fields ---
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.2)],
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: emailController,
                            hint: "Email",
                            icon: Icons.alternate_email_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: passwordController,
                            hint: "Password",
                            icon: Icons.lock_open_rounded,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Login Button ---
                    _buildLoginButton(),
                    const SizedBox(height: 32),

                    // --- Footer ---
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black54, fontSize: 15),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
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

  // --- UI Components ---
  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword ? _obscureText : false,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          if (isPassword)
            InkWell(
              onTap: () => setState(() => _obscureText = !_obscureText),
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade800.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: loading
            ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text(
          "Continue",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
