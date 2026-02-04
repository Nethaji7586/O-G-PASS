import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml
import '../services/outpass_service.dart';

class StudentRequestScreen extends StatefulWidget {
  final String token;
  const StudentRequestScreen({super.key, required this.token});

  @override
  State<StudentRequestScreen> createState() => _StudentRequestScreenState();
}

class _StudentRequestScreenState extends State<StudentRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  DateTime? outTime;
  DateTime? inTime;
  bool loading = false;

  // Utility to format dates cleanly
  String formatDT(DateTime? dt) =>
      dt == null ? 'Not selected' : DateFormat('MMM dd, hh:mm a').format(dt);

  Future<void> pickDateTime(bool isOut) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      isOut ? outTime = selected : inTime = selected;
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() || outTime == null || inTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields"), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => loading = true);
    final success = await OutpassService.requestOutpass(
      token: widget.token,
      reason: _reasonController.text,
      outTime: outTime!,
      inTime: inTime!,
    );
    setState(() => loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Sent!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Outpass"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Outpass Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Reason Field
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Reason for Outpass",
                  hintText: "e.g., Going home for the weekend",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                validator: (val) => val!.isEmpty ? "Reason is required" : null,
              ),
              const SizedBox(height: 24),

              // Date Selection Section
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTimeTile(
                        icon: Icons.logout_rounded,
                        label: "Departure (Out)",
                        value: formatDT(outTime),
                        onTap: () => pickDateTime(true),
                        color: Colors.orange.shade700,
                      ),
                      const Divider(height: 32),
                      _buildTimeTile(
                        icon: Icons.login_rounded,
                        label: "Arrival (In)",
                        value: formatDT(inTime),
                        onTap: () => pickDateTime(false),
                        color: Colors.green.shade700,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                height: 55,
                child: FilledButton(
                  onPressed: loading ? null : submit,
                  style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Submit Request", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile({required IconData icon, required String label, required String value, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.calendar_month, color: Colors.grey),
        ],
      ),
    );
  }
}