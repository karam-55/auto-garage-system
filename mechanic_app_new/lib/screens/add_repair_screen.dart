import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mechanic_provider.dart';

class AddRepairScreen extends StatefulWidget {
  final String bookingId;
  final String? vehicleId;

  const AddRepairScreen({super.key, required this.bookingId, this.vehicleId});

  @override
  State<AddRepairScreen> createState() => _AddRepairScreenState();
}

class _AddRepairScreenState extends State<AddRepairScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  String _selectedStatus = 'PENDING';

  final List<String> _statusOptions = [
    'PENDING',
    'IN_PROGRESS',
    'COMPLETED',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _addRepair() async {
    if (_formKey.currentState!.validate()) {
      final mechanicProvider = context.read<MechanicProvider>();
      final success = await mechanicProvider.addRepair(
        widget.bookingId,
        _descriptionController.text.trim(),
        _selectedStatus,
        double.tryParse(_costController.text),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة العطل بنجاح')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عطل جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إضافة عطل جديد',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'وصف العطل',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال وصف العطل';
                          }
                          return null;
                        },
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
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(
                          labelText: 'التكلفة (ل.س)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      Consumer<MechanicProvider>(
                        builder: (context, mechanicProvider, child) {
                          if (mechanicProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          return ElevatedButton(
                            onPressed: _addRepair,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('إضافة العطل'),
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
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'قيد الانتظار';
      case 'IN_PROGRESS':
        return 'قيد العمل';
      case 'COMPLETED':
        return 'مكتمل';
      default:
        return status;
    }
  }
}
