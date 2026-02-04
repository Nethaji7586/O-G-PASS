import 'package:flutter/material.dart';
import '../services/staff_service.dart';
import 'staff_pending_screen.dart';
import 'login_screen.dart';
import 'all_students_screen.dart'; // fixed import with semicolon
import 'delayed_students_screen.dart';
import 'add_phone_screen.dart';

class StaffDashboard extends StatefulWidget {
  final String userName;
  final String token;

  const StaffDashboard({
    super.key,
    required this.userName,
    required this.token,
  });

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    loadPendingCount();
  }

  Future<void> loadPendingCount() async {
    final count = await StaffService.getPendingCount(widget.token);
    if (mounted) setState(() => pendingCount = count);
  }

  void _navigateToPending() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffPendingScreen(token: widget.token),
      ),
    ).then((_) => loadPendingCount());
  }
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPhoneScreen(
          token: widget.token,
        ),
      ),
    );
  }

  void _navigateToDelayedStudents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DelayedStudentsScreen(token: widget.token),
      ),
    );
  }


  void _navigateToAllStudents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllStudentsScreen(token: widget.token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo.shade900,
        title: const Text(
          "SVGI-GOBI",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Header Section with Logo & Welcome ---
            // --- Header Section with Logo & Welcome ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade900,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Welcome back,",
                    style: TextStyle(color: Colors.indigo.shade100, fontSize: 16),
                  ),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- Dashboard Grid ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildDashCard(
                    title: "Pending",
                    count: pendingCount.toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    onTap: _navigateToPending,
                  ),
                  _buildDashCard(
                    title: "Students",
                    count: "List",
                    icon: Icons.people_outline,
                    color: Colors.blue,
                    onTap: _navigateToAllStudents,
                  ),
                  _buildDashCard(
                    title: "Delayed",
                    count: "View",
                    icon: Icons.timer_off,
                    color: Colors.redAccent,
                    onTap: _navigateToDelayedStudents,
                  ),
                  _buildDashCard(
                    title: "Settings",
                    count: "Profile",
                    icon: Icons.settings,
                    color: Colors.grey,
                    onTap: _navigateToSettings,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Shree Venkateswara Group of Institutions",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to sign out?"),
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
