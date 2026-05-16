import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mechanic_assignment.dart';
import '../../providers/mechanic_provider.dart';

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
    final mechanicProvider = context.read<MechanicProvider>();
    final bookingId = widget.assignment.bookingId;
    final success = await mechanicProvider.updateBookingStatus(
      bookingId,
      _selectedStatus,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة الحجز بنجاح')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديث حالة الصيانة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.assignment.booking?.vehicle != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات السيارة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text('الماركة: ${widget.assignment.booking!.vehicle!.make}'),
                      Text('الموديل: ${widget.assignment.booking!.vehicle!.model}'),
                      if (widget.assignment.booking!.vehicle!.year != null)
                        Text('السنة: ${widget.assignment.booking!.vehicle!.year}'),
                      if (widget.assignment.booking!.vehicle!.licensePlate != null)
                        Text('رقم اللوحة: ${widget.assignment.booking!.vehicle!.licensePlate}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تحديث الحالة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
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
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Consumer<MechanicProvider>(
                      builder: (context, mechanicProvider, child) {
                        if (mechanicProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return ElevatedButton(
                          onPressed: _updateStatus,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('تحديث الحالة'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'IN_PROGRESS':
        return 'جاري العمل';
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
