import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';

class CreateLeaveRequestScreen extends ConsumerStatefulWidget {
  const CreateLeaveRequestScreen({super.key});

  @override
  ConsumerState<CreateLeaveRequestScreen> createState() => _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState extends ConsumerState<CreateLeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _leaveTypeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _leaveTypeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final requestData = {
          'userId': _userIdController.text,
          'leaveType': _leaveTypeController.text,
          'startDate': _startDateController.text,
          'endDate': _endDateController.text,
          'reason': _reasonController.text.isNotEmpty ? _reasonController.text : null,
          'status': 'pending',
        };

        await ref.read(createLeaveRequestProvider(requestData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء طلب الإجازة بنجاح')),
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
        title: const Text('إنشاء طلب إجازة جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'رقم الموظف',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _leaveTypeController,
              decoration: const InputDecoration(
                labelText: 'نوع الإجازة',
                prefixIcon: Icon(Icons.beach_access),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
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
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'السبب (اختياري)',
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
                  : const Text('حفظ طلب الإجازة', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
