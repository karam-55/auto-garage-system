import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';

class CreateLeadScreen extends ConsumerStatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  ConsumerState<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends ConsumerState<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _sourceController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _closingDateController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'new';
  bool _isLoading = false;

  @override
  void dispose() {
    _customerIdController.dispose();
    _sourceController.dispose();
    _estimatedValueController.dispose();
    _closingDateController.dispose();
    _assignedToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final leadData = {
          'customerId': _customerIdController.text.isNotEmpty ? _customerIdController.text : null,
          'source': _sourceController.text.isNotEmpty ? _sourceController.text : null,
          'status': _status,
          'estimatedValue': _estimatedValueController.text.isNotEmpty ? double.parse(_estimatedValueController.text) : null,
          'closingDate': _closingDateController.text.isNotEmpty ? _closingDateController.text : null,
          'assignedTo': _assignedToController.text.isNotEmpty ? _assignedToController.text : null,
          'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        };

        await ref.read(createCrmLeadProvider(leadData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء العميل المحتمل بنجاح')),
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
        title: const Text('إنشاء عميل محتمل جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _customerIdController,
              decoration: const InputDecoration(
                labelText: 'رقم العميل (اختياري)',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'المصدر (اختياري)',
                prefixIcon: Icon(Icons.source),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'الحالة',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'new', child: Text('جديد')),
                DropdownMenuItem(value: 'contacted', child: Text('تم التواصل')),
                DropdownMenuItem(value: 'qualified', child: Text('مؤهل')),
                DropdownMenuItem(value: 'converted', child: Text('محول')),
                DropdownMenuItem(value: 'lost', child: Text('مفقود')),
              ],
              onChanged: (value) {
                setState(() => _status = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estimatedValueController,
              decoration: const InputDecoration(
                labelText: 'القيمة المقدرة (اختياري)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _closingDateController,
              decoration: const InputDecoration(
                labelText: 'تاريخ الإغلاق المتوقع (اختياري)',
                prefixIcon: Icon(Icons.event),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _assignedToController,
              decoration: const InputDecoration(
                labelText: 'المسؤول (اختياري)',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
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
                  : const Text('حفظ العميل المحتمل', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
