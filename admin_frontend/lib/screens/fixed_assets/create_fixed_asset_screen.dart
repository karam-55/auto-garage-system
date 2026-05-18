import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';

class CreateFixedAssetScreen extends ConsumerStatefulWidget {
  const CreateFixedAssetScreen({super.key});

  @override
  ConsumerState<CreateFixedAssetScreen> createState() => _CreateFixedAssetScreenState();
}

class _CreateFixedAssetScreenState extends ConsumerState<CreateFixedAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _acquisitionDateController = TextEditingController();
  final _acquisitionCostController = TextEditingController();
  final _salvageValueController = TextEditingController(text: '0');
  final _usefulLifeYearsController = TextEditingController(text: '10');
  final _depreciationMethodController = TextEditingController(text: 'straight_line');
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _acquisitionDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _acquisitionDateController.dispose();
    _acquisitionCostController.dispose();
    _salvageValueController.dispose();
    _usefulLifeYearsController.dispose();
    _depreciationMethodController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final assetData = {
          'name': _nameController.text,
          'acquisitionDate': _acquisitionDateController.text,
          'acquisitionCost': double.parse(_acquisitionCostController.text),
          'salvageValue': double.parse(_salvageValueController.text),
          'usefulLifeYears': int.parse(_usefulLifeYearsController.text),
          'depreciationMethod': _depreciationMethodController.text,
          'location': _locationController.text.isNotEmpty ? _locationController.text : null,
          'status': 'active',
        };

        await ref.read(createFixedAssetProvider(assetData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الأصل الثابت بنجاح')),
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
        title: const Text('إنشاء أصل ثابت جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الأصل',
                prefixIcon: Icon(Icons.account_balance),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _acquisitionDateController,
              decoration: const InputDecoration(
                labelText: 'تاريخ الشراء',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _acquisitionCostController,
              decoration: const InputDecoration(
                labelText: 'تكلفة الشراء',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _salvageValueController,
              decoration: const InputDecoration(
                labelText: 'قيمة الخردة',
                prefixIcon: Icon(Icons.money_off),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usefulLifeYearsController,
              decoration: const InputDecoration(
                labelText: 'العمر الافتراضي (سنة)',
                prefixIcon: Icon(Icons.schedule),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _depreciationMethodController,
              decoration: const InputDecoration(
                labelText: 'طريقة الإهلاك',
                prefixIcon: Icon(Icons.trending_down),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'الموقع (اختياري)',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
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
                  : const Text('حفظ الأصل الثابت', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
