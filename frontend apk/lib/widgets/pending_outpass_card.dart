import 'package:flutter/material.dart';
import '../services/staff_service.dart';

class PendingOutpassCard extends StatelessWidget {
  final dynamic item;
  final String token;
  final Set<String> selectedIds;
  final VoidCallback onChanged;
  final bool isSelectionMode; // New flag to control checkbox visibility

  const PendingOutpassCard({
    super.key,
    required this.item,
    required this.token,
    required this.selectedIds,
    required this.onChanged,
    this.isSelectionMode = false, // Default to hidden
  });

  String formatDate(String date) {
    try {
      final dt = DateTime.parse(date).toLocal();
      return "${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = item['_id'];
    final bool isSelected = selectedIds.contains(id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      elevation: isSelected ? 4 : 2,
      child: InkWell( // Added for tap feedback
        onTap: isSelectionMode ? () => _toggleSelection(id) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  // Animated Visibility for the Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelectionMode ? 40 : 0,
                    child: isSelectionMode
                        ? Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleSelection(id),
                    )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['student']['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          item['student']['email'],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: item['status']),
                ],
              ),
              const Divider(height: 20),
              _buildInfoRow(Icons.notes, "Reason", item['reason']),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildTimeDetail(Icons.outbox, "Out", item['outTime'])),
                  Expanded(child: _buildTimeDetail(Icons.move_to_inbox, "In", item['inTime'])),
                ],
              ),
              // Only show action buttons if NOT in selection mode
              if (!isSelectionMode) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _handleReject(context, id),
                      child: const Text("Reject", style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _handleApprove(context, id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Approve"),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    onChanged();
  }

  // Helper widgets to keep code clean
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(child: Text("$label: $value", style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildTimeDetail(IconData icon, String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(formatDate(date), style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Future<void> _handleApprove(BuildContext context, String id) async {
    await StaffService.approveOutpass(token, id);
    onChanged();
  }

  Future<void> _handleReject(BuildContext context, String id) async {
    await StaffService.rejectOutpass(token: token, id: id, reason: "Rejected");
    onChanged();
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: Colors.orange.shade800, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}