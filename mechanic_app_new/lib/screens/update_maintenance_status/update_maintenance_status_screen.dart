import 'package:flutter/material.dart';
import '../../domain/entities/mechanic_assignment.dart';

class UpdateMaintenanceStatusScreen extends StatefulWidget {
  final MechanicAssignment assignment;

  const UpdateMaintenanceStatusScreen({super.key, required this.assignment});

  @override
  State<UpdateMaintenanceStatusScreen> createState() => _UpdateMaintenanceStatusScreenState();
}

class _UpdateMaintenanceStatusScreenState extends State<UpdateMaintenanceStatusScreen> {
  final _notesController = TextEditingController();
  String _selectedStatus = 'IN_PROGRESS';

  final List<String> _statusOptions = [
    'IN_PROGRESS',
    'WAITING_PARTS',
    'READY',
    'DELIVERED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.assignment.booking?.status ?? 'IN_PROGRESS';
    _notesController.text = widget.assignment.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    // TODO: Implement status update using Riverpod
    final bookingId = widget.assignment.booking?.id;
    if (bookingId == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث الحالة بنجاح')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديث حالة الصيانة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تحديد حالة الصيانة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'الحالة',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value ?? 'IN_PROGRESS';
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateStatus,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('تحديث الحالة'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'IN_PROGRESS':
        return 'قيد العمل';
      case 'WAITING_PARTS':
        return 'بانتظار القطع';
      case 'READY':
        return 'جاهز';
      case 'DELIVERED':
        return 'تم التسليم';
      case 'CANCELLED':
        return 'ملغي';
      default:
        return status;
    }
  }
}
