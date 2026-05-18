import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';

class CreateMaintenanceContractScreen extends ConsumerStatefulWidget {
  const CreateMaintenanceContractScreen({super.key});

  @override
  ConsumerState<CreateMaintenanceContractScreen> createState() => _CreateMaintenanceContractScreenState();
}

class _CreateMaintenanceContractScreenState extends ConsumerState<CreateMaintenanceContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _vehicleIdController = TextEditingController();
  final _contractNumberController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _serviceIntervalKmController = TextEditingController();
  final _serviceIntervalDaysController = TextEditingController();
  final _lastServiceKmController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _vehicleIdController.dispose();
    _contractNumberController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _serviceIntervalKmController.dispose();
    _serviceIntervalDaysController.dispose();
    _lastServiceKmController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final contractData = {
          'customerId': _customerIdController.text,
          'vehicleId': _vehicleIdController.text,
          'contractNumber': _contractNumberController.text.isNotEmpty ? _contractNumberController.text : null,
          'startDate': _startDateController.text,
          'endDate': _endDateController.text,
          'serviceIntervalKm': _serviceIntervalKmController.text.isNotEmpty ? int.parse(_serviceIntervalKmController.text) : null,
          'serviceIntervalDays': _serviceIntervalDaysController.text.isNotEmpty ? int.parse(_serviceIntervalDaysController.text) : null,
          'lastServiceKm': _lastServiceKmController.text.isNotEmpty ? int.parse(_lastServiceKmController.text) : null,
          'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        };

        await ref.read(createMaintenanceContractProvider(contractData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء عقد الصيانة بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء عقد صيانة جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _customerIdController,
              decoration: const InputDecoration(
                labelText: 'رقم العميل',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vehicleIdController,
              decoration: const InputDecoration(
                labelText: 'رقم السيارة',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contractNumberController,
              decoration: const InputDecoration(
                labelText: 'رقم العقد (اختياري)',
                prefixIcon: Icon(Icons.receipt),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'تاريخ البدء',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _endDateController,
              decoration: const InputDecoration(
                labelText: 'تاريخ الانتهاء',
                prefixIcon: Icon(Icons.event),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceIntervalKmController,
              decoration: const InputDecoration(
                labelText: 'فترة الصيانة (كم) - اختياري',
                prefixIcon: Icon(Icons.speed),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceIntervalDaysController,
              decoration: const InputDecoration(
                labelText: 'فترة الصيانة (أيام) - اختياري',
                prefixIcon: Icon(Icons.schedule),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastServiceKmController,
              decoration: const InputDecoration(
                labelText: 'آخر صيانة (كم) - اختياري',
                prefixIcon: Icon(Icons.speed),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ عقد الصيانة', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
