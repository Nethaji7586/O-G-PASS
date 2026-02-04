import 'package:flutter/material.dart';
import '../services/staff_service.dart';

class AllStudentsScreen extends StatefulWidget {
  final String token;
  const AllStudentsScreen({super.key, required this.token});

  @override
  State<AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends State<AllStudentsScreen> {
  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final data = await StaffService.getAllStudents(widget.token);
    setState(() {
      students = data;
      filteredStudents = data;
      isLoading = false;
    });
  }

  void filterStudents(String query) {
    final searchLower = query.toLowerCase();

    final filtered = students.where((student) {
      final name = (student['name'] ?? '').toLowerCase();
      final email = (student['email'] ?? '').toLowerCase();
      final phone = (student['phone'] ?? '').toString();

      return name.contains(searchLower) ||
          email.contains(searchLower) ||
          phone.contains(searchLower);
    }).toList();

    setState(() {
      filteredStudents = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Students")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: filterStudents,
              decoration: InputDecoration(
                hintText: "Search by name, email or phone",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 📋 LIST
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text("No students found"))
                : ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                final phone = student['phone'];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      student['name'][0].toUpperCase(),
                    ),
                  ),
                  title: Text(student['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student['email']),
                      const SizedBox(height: 2),
                      Text(
                        phone != null
                            ? " $phone"
                            : " No phone",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
