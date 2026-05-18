import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';

class CreateManufacturingOrderScreen extends ConsumerStatefulWidget {
  const CreateManufacturingOrderScreen({super.key});

  @override
  ConsumerState<CreateManufacturingOrderScreen> createState() => _CreateManufacturingOrderScreenState();
}

class _CreateManufacturingOrderScreenState extends ConsumerState<CreateManufacturingOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bomIdController = TextEditingController();
  final _quantityToProduceController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _bomIdController.dispose();
    _quantityToProduceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final orderData = {
          'bomId': int.parse(_bomIdController.text),
          'quantityToProduce': int.parse(_quantityToProduceController.text),
          'producedQuantity': 0,
          'status': 'pending',
          'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        };

        await ref.read(createManufacturingOrderProvider(orderData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء أمر الإنتاج بنجاح')),
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
        title: const Text('إنشاء أمر إنتاج جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _bomIdController,
              decoration: const InputDecoration(
                labelText: 'رقم قائمة المواد',
                prefixIcon: Icon(Icons.list_alt),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityToProduceController,
              decoration: const InputDecoration(
                labelText: 'الكمية المطلوبة',
                prefixIcon: Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
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
                  : const Text('حفظ أمر الإنتاج', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
