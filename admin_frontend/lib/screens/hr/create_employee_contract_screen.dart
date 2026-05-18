import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';

class CreateEmployeeContractScreen extends ConsumerStatefulWidget {
  const CreateEmployeeContractScreen({super.key});

  @override
  ConsumerState<CreateEmployeeContractScreen> createState() => _CreateEmployeeContractScreenState();
}

class _CreateEmployeeContractScreenState extends ConsumerState<CreateEmployeeContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _contractTypeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _baseSalaryController = TextEditingController();
  final _benefitsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _contractTypeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _baseSalaryController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final contractData = {
          'userId': _userIdController.text,
          'contractType': _contractTypeController.text,
          'startDate': _startDateController.text,
          'endDate': _endDateController.text.isNotEmpty ? _endDateController.text : null,
          'baseSalary': _baseSalaryController.text.isNotEmpty ? double.parse(_baseSalaryController.text) : null,
          'benefits': _benefitsController.text.isNotEmpty ? _benefitsController.text : null,
        };

        await ref.read(createEmployeeContractProvider(contractData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء عقد الموظف بنجاح')),
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
        title: const Text('إنشاء عقد موظف جديد'),
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
              controller: _contractTypeController,
              decoration: const InputDecoration(
                labelText: 'نوع العقد',
                prefixIcon: Icon(Icons.description),
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
                labelText: 'تاريخ الانتهاء (اختياري)',
                prefixIcon: Icon(Icons.event),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _baseSalaryController,
              decoration: const InputDecoration(
                labelText: 'الراتب الأساسي (اختياري)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _benefitsController,
              decoration: const InputDecoration(
                labelText: 'المزايا (اختياري)',
                prefixIcon: Icon(Icons.card_giftcard),
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
                  : const Text('حفظ عقد الموظف', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
