import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AddPhoneScreen extends StatefulWidget {
  final String token;

  const AddPhoneScreen({super.key, required this.token});

  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _phoneAlreadyAdded = false;

  String _name = "";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getProfile(
      token: widget.token,
    );

    if (profile != null) {
      setState(() {
        _name = profile["name"] ?? "";
        _email = profile["email"] ?? "";

        if (profile["phone"] != null &&
            profile["phone"].toString().isNotEmpty) {
          _phoneController.text = profile["phone"];
          _phoneAlreadyAdded = true;
        }
      });
    }
  }

  void _submitPhone() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 10-digit phone number")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await AuthService.addPhone(
      token: widget.token,
      phone: phone,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number added successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone number already added or failed"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Phone Number"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // 👤 USER NAME
            Text(
              _name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 📧 EMAIL
            Text(
              _email,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),


            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              enabled: !_phoneAlreadyAdded,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Phone Number",
                hintText: "9876543210",
                suffixIcon: _phoneAlreadyAdded
                    ? const Icon(Icons.lock, color: Colors.grey)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // 💾 SAVE BUTTON
            ElevatedButton(
              onPressed:
              (_isLoading || _phoneAlreadyAdded) ? null : _submitPhone,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Phone Number"),
            ),
          ],
        ),
      ),
    );
  }
}
