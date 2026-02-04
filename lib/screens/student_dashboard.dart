import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'student_request_screen.dart';
import 'add_phone_screen.dart';
import 'student_history_screen.dart'; // Passes history

class StudentDashboard extends StatelessWidget {
  final String userName;
  final String token;

  const StudentDashboard({
    super.key,
    required this.userName,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo.shade900,
        title: const Text("SVGI-GOBI",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Header / Welcome Section ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Hey $userName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "What would you like to do today?",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const Spacer(),

          // --- Action Buttons Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildActionButton(
                  context,
                  title: "Request Outpass",
                  subtitle: "Apply for a new pass",
                  icon: Icons.assignment_rounded,
                  color: Colors.indigo.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentRequestScreen(token: token),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  context,
                  title: "Passes",
                  subtitle: "View your outpass history",
                  icon: Icons.history_rounded,
                  color: Colors.green.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentHistoryScreen(token: token),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  context,
                  title: "Settings",
                  subtitle: "Update Mobile Number",
                  icon: Icons.settings_rounded,
                  color: Colors.blueGrey.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddPhoneScreen(token: token),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Spacer(flex: 2),

          // --- Footer ---
          const Text(
            "SVGI Student Portal",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper method to build consistent action buttons
  Widget _buildActionButton(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
