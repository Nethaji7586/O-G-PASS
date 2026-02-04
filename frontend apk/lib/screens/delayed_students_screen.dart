import 'package:flutter/material.dart';
import '../services/staff_service.dart';

class DelayedStudentsScreen extends StatefulWidget {
  final String token;
  const DelayedStudentsScreen({super.key, required this.token});

  @override
  State<DelayedStudentsScreen> createState() => _DelayedStudentsScreenState();
}

class _DelayedStudentsScreenState extends State<DelayedStudentsScreen> {
  late Future<List<dynamic>> delayedFuture;
  List<dynamic> allStudents = [];
  List<dynamic> filteredStudents = [];

  final TextEditingController _searchController = TextEditingController();
  final Color primaryIndigo = Colors.indigo.shade900;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    delayedFuture = StaffService.getDelayedStudents(widget.token);
    delayedFuture.then((data) {
      setState(() {
        allStudents = data;
        filteredStudents = data;
      });
    });
  }

  void _filterSearch(String query) {
    setState(() {
      filteredStudents = allStudents
          .where((s) =>
      s['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          s['email'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sort By", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text("Name (A-Z)"),
                onTap: () {
                  setState(() => filteredStudents.sort((a, b) => a['name'].compareTo(b['name'])));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text("Highest Delay First"),
                onTap: () {
                  setState(() => filteredStudents.sort((a, b) => b['delayMinutes'].compareTo(a['delayMinutes'])));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryIndigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search student...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: _filterSearch,
        )
            : const Text("Delayed Students", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  filteredStudents = allStudents;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: delayedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryIndigo));
          }
          if (snapshot.hasError) return const Center(child: Text("Error loading data"));

          if (filteredStudents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text("No students found", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              final s = filteredStudents[index];
              return _buildStudentCard(s);
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> s) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.shade50,
                  child: Icon(Icons.person, color: primaryIndigo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name'] ?? "Unknown", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      Text(s['email'] ?? "-", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text("${s['delayMinutes']}m late", style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            _infoRow(Icons.access_time_rounded, "Expected: ", formatTime(s['inTime'])),
            const SizedBox(height: 4),
            _infoRow(Icons.login_rounded, "Actual In: ", formatTime(s['actualInTime']), iconColor: primaryIndigo),
            if (s['phone']?.toString().isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              _infoRow(Icons.phone_iphone, "", s['phone'].toString()),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text("Reason: ${s['reason'] ?? 'Not specified'}", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey),
        const SizedBox(width: 8),
        if (label.isNotEmpty) Text(label, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
        Text(value),
      ],
    );
  }

  String formatTime(String? iso) {
    if (iso == null) return "-";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) { return "-"; }
  }
}