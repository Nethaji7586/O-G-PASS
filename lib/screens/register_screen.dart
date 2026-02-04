import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "student";
  bool loading = false;

  void handleRegister() async {
    setState(() => loading = true);

    final success = await AuthService.register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      role: role,
    );

    setState(() => loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration failed ")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),

            // Role selection
            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(
                  value: "student",
                  child: Text("Student"),
                ),
                DropdownMenuItem(
                  value: "staff",
                  child: Text("Staff"),
                ),
              ],
              onChanged: (value) {
                setState(() => role = value!);
              },
              decoration: const InputDecoration(
                labelText: "Role",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : handleRegister,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
