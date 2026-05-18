import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import '../../core/providers/financial_providers.dart';
import 'models/purchase_order.dart';

class CreatePurchaseOrderScreen extends ConsumerStatefulWidget {
  const CreatePurchaseOrderScreen({super.key});

  @override
  ConsumerState<CreatePurchaseOrderScreen> createState() => _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends ConsumerState<CreatePurchaseOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVendorId;
  final _orderDateController = TextEditingController();
  final _expectedDateController = TextEditingController();
  final _notesController = TextEditingController();
  final List<PurchaseOrderLine> _lines = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _orderDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _orderDateController.dispose();
    _expectedDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return _lines.fold(0.0, (sum, line) => sum + line.totalPrice);
  }

  void _addLine() {
    setState(() {
      _lines.add(PurchaseOrderLine(
        id: 0,
        purchaseOrderId: 0,
        inventoryVariantId: '',
        quantityOrdered: 1,
        quantityReceived: 0,
        unitPrice: 0.0,
        totalPrice: 0.0,
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
          _lines[index] = PurchaseOrderLine(
            id: _lines[index].id,
            purchaseOrderId: _lines[index].purchaseOrderId,
            inventoryVariantId: value,
            quantityOrdered: _lines[index].quantityOrdered,
            quantityReceived: _lines[index].quantityReceived,
            unitPrice: _lines[index].unitPrice,
            totalPrice: _lines[index].quantityOrdered * _lines[index].unitPrice,
            createdAt: _lines[index].createdAt,
          );
          break;
        case 'quantity':
          final qty = int.tryParse(value) ?? 0;
          _lines[index] = PurchaseOrderLine(
            id: _lines[index].id,
            purchaseOrderId: _lines[index].purchaseOrderId,
            inventoryVariantId: _lines[index].inventoryVariantId,
            quantityOrdered: qty,
            quantityReceived: _lines[index].quantityReceived,
            unitPrice: _lines[index].unitPrice,
            totalPrice: qty * _lines[index].unitPrice,
            createdAt: _lines[index].createdAt,
          );
          break;
        case 'price':
          final price = double.tryParse(value) ?? 0.0;
          _lines[index] = PurchaseOrderLine(
            id: _lines[index].id,
            purchaseOrderId: _lines[index].purchaseOrderId,
            inventoryVariantId: _lines[index].inventoryVariantId,
            quantityOrdered: _lines[index].quantityOrdered,
            quantityReceived: _lines[index].quantityReceived,
            unitPrice: price,
            totalPrice: _lines[index].quantityOrdered * price,
            createdAt: _lines[index].createdAt,
          );
          break;
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedVendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار مورد')),
      );
      return;
    }
    
    if (_formKey.currentState?.validate() ?? false) {
      if (_lines.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب إضافة صنف واحد على الأقل')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final orderData = {
          'vendorId': _selectedVendorId,
          'orderDate': _orderDateController.text,
          'expectedDate': _expectedDateController.text.isNotEmpty ? _expectedDateController.text : null,
          'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
          'status': 'pending',
          'lines': _lines.map((line) => {
            'inventoryVariantId': line.inventoryVariantId,
            'quantityOrdered': line.quantityOrdered,
            'unitPrice': line.unitPrice,
          }).toList(),
        };

        await ref.read(createPurchaseOrderProvider(orderData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء أمر الشراء بنجاح')),
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
    final vendorsAsync = ref.watch(vendorsProvider);
    final variantsAsync = ref.watch(inventoryVariantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء أمر شراء جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            vendorsAsync.when(
              data: (vendors) {
                return DropdownButtonFormField<String>(
                  value: _selectedVendorId,
                  decoration: const InputDecoration(
                    labelText: 'المورد',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  items: vendors.map<DropdownMenuItem<String>>((vendor) {
                    return DropdownMenuItem<String>(
                      value: vendor['id'].toString(),
                      child: Text(vendor['name'] ?? 'بدون اسم'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedVendorId = value);
                  },
                  validator: (value) => value == null ? 'مطلوب' : null,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Text('خطأ في تحميل الموردين'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orderDateController,
              decoration: const InputDecoration(
                labelText: 'تاريخ الأمر',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expectedDateController,
              decoration: const InputDecoration(
                labelText: 'التاريخ المتوقع (اختياري)',
                prefixIcon: Icon(Icons.event),
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
            const Text('الأصناف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      variantsAsync.when(
                        data: (variants) {
                          return DropdownButtonFormField<String>(
                            value: line.inventoryVariantId.isEmpty ? null : line.inventoryVariantId,
                            decoration: const InputDecoration(
                              labelText: 'الصنف',
                              border: OutlineInputBorder(),
                            ),
                            items: variants.map<DropdownMenuItem<String>>((variant) {
                              return DropdownMenuItem<String>(
                                value: variant['id'].toString(),
                                child: Text(variant['name'] ?? 'بدون اسم'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _updateLine(index, 'variantId', value);
                              }
                            },
                            validator: (value) => value == null ? 'مطلوب' : null,
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => const Text('خطأ في تحميل الأصناف'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: line.quantityOrdered.toString(),
                              decoration: const InputDecoration(
                                labelText: 'الكمية',
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
                              initialValue: line.unitPrice.toString(),
                              decoration: const InputDecoration(
                                labelText: 'السعر',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateLine(index, 'price', value),
                              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الإجمالي: ${line.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('إجمالي الأمر:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
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
                  : const Text('حفظ أمر الشراء', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
