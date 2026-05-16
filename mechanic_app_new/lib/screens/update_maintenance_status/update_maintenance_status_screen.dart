import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mechanic_assignment.dart';
import '../../presentation/providers/booking_provider.dart';

class UpdateMaintenanceStatusScreen extends ConsumerStatefulWidget {
  final MechanicAssignment assignment;

  const UpdateMaintenanceStatusScreen({super.key, required this.assignment});

  @override
  ConsumerState<UpdateMaintenanceStatusScreen> createState() => _UpdateMaintenanceStatusScreenState();
}

class _UpdateMaintenanceStatusScreenState extends ConsumerState<UpdateMaintenanceStatusScreen> {
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
    final bookingId = widget.assignment.booking?.id;
    if (bookingId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: لم يتم العثور على معرف الحجز')),
        );
      }
      return;
    }

    try {
      await ref.read(bookingStateProvider.notifier).updateBookingStatus(bookingId, _selectedStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث حالة الحجز بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحديث الحالة: $e')),
        );
      }
    }
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
