import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/staff_service.dart';

class StaffPendingScreen extends StatefulWidget {
  final String token;
  const StaffPendingScreen({super.key, required this.token});

  @override
  State<StaffPendingScreen> createState() => _StaffPendingScreenState();
}

class _StaffPendingScreenState extends State<StaffPendingScreen> {
  List<dynamic> pendingRequests = [];
  List<dynamic> filteredRequests = [];
  Set<String> selectedIds = {};
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    setState(() => isLoading = true);
    try {
      final requests = await StaffService.getPendingOutpasses(widget.token);
      setState(() {
        pendingRequests = requests;
        filteredRequests = requests;
        selectedIds.clear();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Failed to load: $e");
    }
  }

  String formatTime(dynamic timeData) {
    if (timeData == null) return "-";

    try {
      String dateStr;

      // Case 1: MongoDB $date format
      if (timeData is Map && timeData.containsKey('\$date')) {
        dateStr = timeData['\$date'];
      }
      // Case 2: Normal ISO string
      else {
        dateStr = timeData.toString();
      }

      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return "-";
    }
  }


  void searchRequests(String query) {
    setState(() {
      filteredRequests = pendingRequests.where((req) {
        final student = req['student'] ?? {};
        final name = (student['name'] ?? '').toString().toLowerCase();
        final email = (student['email'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
      }).toList();
    });
  }

  void toggleSelect(String id) => setState(() => selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id));

  void selectAllToggle() {
    setState(() {
      if (selectedIds.length == filteredRequests.length) {
        selectedIds.clear();
      } else {
        selectedIds = filteredRequests.map((r) => r['_id'].toString()).toSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pending Outpasses", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${pendingRequests.length} requests total", style: theme.textTheme.bodySmall),
          ],
        ),
        actions: [
          if (filteredRequests.isNotEmpty)
            TextButton.icon(
              onPressed: selectAllToggle,
              icon: Icon(selectedIds.length == filteredRequests.length ? Icons.deselect : Icons.select_all),
              label: Text(selectedIds.length == filteredRequests.length ? "None" : "All"),
            )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                ? _buildEmptyState()
                : _buildRequestList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBulkActionBar(theme),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: theme.primaryColor.withOpacity(0.05),
      child: TextField(
        controller: _searchController,
        onChanged: searchRequests,
        decoration: InputDecoration(
          hintText: "Search student name or ID...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
            _searchController.clear();
            searchRequests('');
          })
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildRequestList() {
    return RefreshIndicator(
      onRefresh: fetchPendingRequests,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Space for bottom bar
        itemCount: filteredRequests.length,
        itemBuilder: (context, index) {
          final req = filteredRequests[index];
          final id = req['_id'].toString();
          final isSelected = selectedIds.contains(id);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: ExpansionTile(
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              leading: Checkbox(
                  value: isSelected,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (_) => toggleSelect(id)
              ),
              title: Text(req['student']?['name'] ?? "Unknown Student", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(req['student']?['email'] ?? "", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      _infoRow(Icons.description_outlined, "Reason", req['reason'] ?? "No reason provided"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _infoRow(Icons.logout, "Out", formatTime(req['outTime']))),
                          Expanded(child: _infoRow(Icons.login, "In", formatTime(req['inTime']))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () => handleAction(id, false),
                              icon: const Icon(Icons.close),
                              label: const Text("Reject"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () => handleAction(id, true),
                              icon: const Icon(Icons.check),
                              label: const Text("Approve"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("All caught up!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const Text("No pending outpass requests found."),
        ],
      ),
    );
  }

  Widget? _buildBulkActionBar(ThemeData theme) {
    if (selectedIds.isEmpty) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text("${selectedIds.length} selected", style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(
              onPressed: () => bulkAction(false),
              child: const Text("Reject", style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor,foregroundColor: Colors.white,),
              onPressed: () => bulkAction(true),
              child: const Text("Approve"),
            ),
          ],
        ),
      ),
    );
  }

  // Logic remains similar but with UI refinements...
  Future<void> handleAction(String id, bool approve) async {
    final confirm = await _showConfirmDialog(approve ? "Approve" : "Reject", "this request?");
    if (confirm != true) return;

    setState(() => isLoading = true);
    bool res = approve
        ? await StaffService.approveOutpass(widget.token, id)
        : await StaffService.rejectOutpass(token: widget.token, id: id, reason: "Rejected by staff");

    await fetchPendingRequests();
    _showSnackBar(res ? (approve ? "Approved" : "Rejected") : "Action failed");
  }

  Future<void> bulkAction(bool approve) async {
    final confirm = await _showConfirmDialog(approve ? "Approve" : "Reject", "${selectedIds.length} selected requests?");
    if (confirm != true) return;

    setState(() => isLoading = true);
    for (var id in selectedIds) {
      if (approve) await StaffService.approveOutpass(widget.token, id);
      else await StaffService.rejectOutpass(token: widget.token, id: id, reason: "Bulk Rejected");
    }
    await fetchPendingRequests();
    _showSnackBar("Action applied to ${selectedIds.length} items");
  }

  void _showSnackBar(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  Future<bool?> _showConfirmDialog(String t, String m) => showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
          title: Text(t),
          content: Text("Are you sure you want to $m"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: t == "Reject" ? Colors.red : Colors.green),
                onPressed: () => Navigator.pop(context, true),
                child: Text(t, style: const TextStyle(color: Colors.white))
            ),
          ]
      )
  );
}