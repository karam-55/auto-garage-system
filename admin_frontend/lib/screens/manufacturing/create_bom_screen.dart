import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/bill_of_materials.dart';

class CreateBomScreen extends ConsumerStatefulWidget {
  const CreateBomScreen({super.key});

  @override
  ConsumerState<CreateBomScreen> createState() => _CreateBomScreenState();
}

class _CreateBomScreenState extends ConsumerState<CreateBomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serviceIdController = TextEditingController();
  final _quantityOutputController = TextEditingController(text: '1');
  final List<BomLine> _lines = [];
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _serviceIdController.dispose();
    _quantityOutputController.dispose();
    super.dispose();
  }

  void _addLine() {
    setState(() {
      _lines.add(BomLine(
        id: 0,
        bomId: 0,
        inputVariantId: '',
        quantityRequired: 1,
        unitCost: 0.0,
        createdAt: DateTime.now(),
      ));
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines.removeAt(index);
    });
  }

  void _updateLine(int index, String field, dynamic value) {
    setState(() {
      switch (field) {
        case 'variantId':
          _lines[index] = BomLine(
            id: _lines[index].id,
            bomId: _lines[index].bomId,
            inputVariantId: value,
            quantityRequired: _lines[index].quantityRequired,
            unitCost: _lines[index].unitCost,
            createdAt: _lines[index].createdAt,
          );
          break;
        case 'quantity':
          final qty = int.tryParse(value) ?? 0;
          _lines[index] = BomLine(
            id: _lines[index].id,
            bomId: _lines[index].bomId,
            inputVariantId: _lines[index].inputVariantId,
            quantityRequired: qty,
            unitCost: _lines[index].unitCost,
            createdAt: _lines[index].createdAt,
          );
          break;
        case 'cost':
          final cost = double.tryParse(value) ?? 0.0;
          _lines[index] = BomLine(
            id: _lines[index].id,
            bomId: _lines[index].bomId,
            inputVariantId: _lines[index].inputVariantId,
            quantityRequired: _lines[index].quantityRequired,
            unitCost: cost,
            createdAt: _lines[index].createdAt,
          );
          break;
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_lines.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب إضافة صنف واحد على الأقل')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final bomData = {
          'name': _nameController.text,
          'serviceId': _serviceIdController.text.isNotEmpty ? _serviceIdController.text : null,
          'quantityOutput': int.parse(_quantityOutputController.text),
          'isActive': _isActive,
          'lines': _lines.map((line) => {
            'inputVariantId': line.inputVariantId,
            'quantityRequired': line.quantityRequired,
            'unitCost': line.unitCost,
          }).toList(),
        };

        await ref.read(createBomProvider(bomData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء قائمة المواد بنجاح')),
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
        title: const Text('إنشاء قائمة مواد جديدة'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم قائمة المواد',
                prefixIcon: Icon(Icons.list_alt),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceIdController,
              decoration: const InputDecoration(
                labelText: 'رقم الخدمة (اختياري)',
                prefixIcon: Icon(Icons.build),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityOutputController,
              decoration: const InputDecoration(
                labelText: 'كمية الإنتاج',
                prefixIcon: Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('نشط'),
              subtitle: const Text('تفعيل قائمة المواد للاستخدام'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            const SizedBox(height: 24),
            const Text('الأصناف المطلوبة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._lines.asMap().entries.map((entry) {
              final index = entry.key;
              final line = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('صنف ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeLine(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: line.inputVariantId,
                        decoration: const InputDecoration(
                          labelText: 'رقم الصنف',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _updateLine(index, 'variantId', value),
                        validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: line.quantityRequired.toString(),
                              decoration: const InputDecoration(
                                labelText: 'الكمية المطلوبة',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateLine(index, 'quantity', value),
                              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: line.unitCost.toString(),
                              decoration: const InputDecoration(
                                labelText: 'التكلفة',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateLine(index, 'cost', value),
                              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addLine,
              icon: const Icon(Icons.add),
              label: const Text('إضافة صنف'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
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
                  : const Text('حفظ قائمة المواد', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
