import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';

class CreateInventoryTransferScreen extends ConsumerStatefulWidget {
  const CreateInventoryTransferScreen({super.key});

  @override
  ConsumerState<CreateInventoryTransferScreen> createState() => _CreateInventoryTransferScreenState();
}

class _CreateInventoryTransferScreenState extends ConsumerState<CreateInventoryTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVariantId;
  String? _selectedFromWarehouseId;
  String? _selectedToWarehouseId;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedVariantId == null || _selectedFromWarehouseId == null || _selectedToWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار الصنف والمستودع المصدر والمستودع الوجهة')),
      );
      return;
    }
    
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final transferData = {
          'variantId': _selectedVariantId,
          'fromWarehouseId': _selectedFromWarehouseId,
          'toWarehouseId': _selectedToWarehouseId,
          'quantity': int.parse(_quantityController.text),
          'status': 'pending',
          'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        };

        await ref.read(createInventoryTransferProvider(transferData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء عملية النقل بنجاح')),
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
    final warehousesAsync = ref.watch(warehousesProvider);
    final variantsAsync = ref.watch(inventoryVariantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء عملية نقل مخزون'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            variantsAsync.when(
              data: (variants) {
                return DropdownButtonFormField<String>(
                  value: _selectedVariantId,
                  decoration: const InputDecoration(
                    labelText: 'الصنف',
                    prefixIcon: Icon(Icons.inventory_2),
                    border: OutlineInputBorder(),
                  ),
                  items: variants.map<DropdownMenuItem<String>>((variant) {
                    return DropdownMenuItem<String>(
                      value: variant['id'].toString(),
                      child: Text(variant['name'] ?? 'بدون اسم'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedVariantId = value);
                  },
                  validator: (value) => value == null ? 'مطلوب' : null,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Text('خطأ في تحميل الأصناف'),
            ),
            const SizedBox(height: 16),
            warehousesAsync.when(
              data: (warehouses) {
                return DropdownButtonFormField<String>(
                  value: _selectedFromWarehouseId,
                  decoration: const InputDecoration(
                    labelText: 'من مستودع',
                    prefixIcon: Icon(Icons.warehouse),
                    border: OutlineInputBorder(),
                  ),
                  items: warehouses.map<DropdownMenuItem<String>>((warehouse) {
                    return DropdownMenuItem<String>(
                      value: warehouse['id'].toString(),
                      child: Text(warehouse['name'] ?? 'بدون اسم'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedFromWarehouseId = value);
                  },
                  validator: (value) => value == null ? 'مطلوب' : null,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Text('خطأ في تحميل المستودعات'),
            ),
            const SizedBox(height: 16),
            warehousesAsync.when(
              data: (warehouses) {
                return DropdownButtonFormField<String>(
                  value: _selectedToWarehouseId,
                  decoration: const InputDecoration(
                    labelText: 'إلى مستودع',
                    prefixIcon: Icon(Icons.warehouse),
                    border: OutlineInputBorder(),
                  ),
                  items: warehouses.map<DropdownMenuItem<String>>((warehouse) {
                    return DropdownMenuItem<String>(
                      value: warehouse['id'].toString(),
                      child: Text(warehouse['name'] ?? 'بدون اسم'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedToWarehouseId = value);
                  },
                  validator: (value) => value == null ? 'مطلوب' : null,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Text('خطأ في تحميل المستودعات'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'الكمية',
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
                  : const Text('حفظ عملية النقل', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
