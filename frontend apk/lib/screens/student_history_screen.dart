import 'package:flutter/material.dart';
import '../services/outpass_service.dart';
import 'package:intl/intl.dart';

class StudentHistoryScreen extends StatefulWidget {
  final String token;
  const StudentHistoryScreen({super.key, required this.token});

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  late Future<List<dynamic>> history;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() {
    setState(() {
      history = OutpassService.getMyOutpasses(widget.token);
    });
  }

  // --- FIX: Logic to handle both Object and ISO String ---
  String formatDate(dynamic timeData) {
    if (timeData == null) return "-";

    try {
      // 1. If backend sends the object: { "date": "DD-MM-YYYY", "time": "HH:mm" }
      if (timeData is Map) {
        final String date = (timeData['date'] ?? '').toString();
        final String time = (timeData['time'] ?? '').toString();
        if (date.isEmpty) return "-";
        return "$date $time";
      }

      // 2. If backend sends raw ISO String
      final String timeStr = timeData.toString();
      final dt = DateTime.tryParse(timeStr);
      if (dt != null) {
        return DateFormat("dd-MM-yyyy HH:mm").format(dt.toLocal());
      }

      return timeStr;
    } catch (e) {
      return "-";
    }
  }

  Future<void> confirmReached(String id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Return"),
        content: const Text("Have you reached the campus?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (result == true) {
      final success = await OutpassService.reachedOutpass(widget.token, id);
      if (success) loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Outpass History"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Outpass History"));
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => loadHistory(),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final String id = item['_id']?.toString() ?? '';
                final String reason = item['reason'] ?? 'No Reason';
                final String status = item['status']?.toString().toLowerCase() ?? '';
                final bool reached = item['reached'] ?? false;

                // Extracting dates safely using the fix function
                final String outTime = formatDate(item['outTime']);
                final String inTime = formatDate(item['inTime']);

                // Handle nested staff object
                final String staffName = item['staff'] != null
                    ? (item['staff'] is Map ? item['staff']['name'] : item['staff'])
                    : "Not yet reviewed";

                Color statusColor = status == "approved"
                    ? Colors.green
                    : (status == "pending" ? Colors.orange : Colors.red);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(reason, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _infoRow(Icons.calendar_today_outlined, "Out", outTime),
                        _infoRow(Icons.keyboard_return, "In (Expected)", inTime),
                        _infoRow(Icons.person_outline, "Staff", staffName),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: (status == "approved" && !reached)
                              ? ElevatedButton.icon(
                            onPressed: () => confirmReached(id),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text("Mark Reached"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          )
                              : (status == "pending")
                              ? TextButton.icon(
                            onPressed: () async {
                              final ok = await OutpassService.cancelOutpass(widget.token, id);
                              if (ok) loadHistory();
                            },
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            label: const Text("Cancel Request", style: TextStyle(color: Colors.red)),
                          )
                              : (reached)
                              ? const Text("✅ Trip Completed", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}