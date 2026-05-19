import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/sales_order.dart';

class CreateSalesOrderScreen extends ConsumerStatefulWidget {
  const CreateSalesOrderScreen({super.key});

  @override
  ConsumerState<CreateSalesOrderScreen> createState() => _CreateSalesOrderScreenState();
}

class _CreateSalesOrderScreenState extends ConsumerState<CreateSalesOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  final _dateController = TextEditingController();
  final _expectedDateController = TextEditingController();
  final _notesController = TextEditingController();
  final List<SalesOrderLine> _lines = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _dateController.dispose();
    _expectedDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return _lines.fold(0.0, (sum, line) => sum + line.lineTotal);
  }

  void _addLine() {
    setState(() {
      _lines.add(SalesOrderLine(
        id: 0,
        salesOrderId: 0,
        serviceId: null,
        inventoryVariantId: null,
        description: null,
        quantity: 1,
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
        case 'description':
          _lines[index] = SalesOrderLine(
            id: _lines[index].id,
            salesOrderId: _lines[index].salesOrderId,
            serviceId: _lines[index].serviceId,
            inventoryVariantId: _lines[index].inventoryVariantId,
            description: value,
            quantity: _lines[index].quantity,
            unitPrice: _lines[index].unitPrice,
            totalPrice: _lines[index].quantity * _lines[index].unitPrice,
            createdAt: _lines[index].createdAt,
          );
          break;
        case 'quantity':
          final qty = int.tryParse(value) ?? 0;
          _lines[index] = SalesOrderLine(
            id: _lines[index].id,
            salesOrderId: _lines[index].salesOrderId,
            serviceId: _lines[index].serviceId,
            inventoryVariantId: _lines[index].inventoryVariantId,
            description: _lines[index].description,
            quantity: qty,
            unitPrice: _lines[index].unitPrice,
            totalPrice: qty * _lines[index].unitPrice,
            createdAt: _lines[index].createdAt,
          );
          break;
        case 'price':
          final price = double.tryParse(value) ?? 0.0;
          _lines[index] = SalesOrderLine(
            id: _lines[index].id,
            salesOrderId: _lines[index].salesOrderId,
            serviceId: _lines[index].serviceId,
            inventoryVariantId: _lines[index].inventoryVariantId,
            description: _lines[index].description,
            quantity: _lines[index].quantity,
            unitPrice: price,
            totalPrice: _lines[index].quantity * price,
            createdAt: _lines[index].createdAt,
          );
          break;
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار عميل')),
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
          'customerId': _selectedCustomerId,
          'orderDate': _dateController.text,
          'expectedDate': _expectedDateController.text.isNotEmpty ? _expectedDateController.text : null,
          'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
          'status': 'pending',
          'lines': _lines.map((line) => {
            'description': line.description,
            'quantity': line.quantity,
            'unitPrice': line.unitPrice,
          }).toList(),
        };

        await ref.read(createSalesOrderProvider(orderData).future);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء أمر البيع بنجاح')),
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
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء أمر بيع جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            customersAsync.when(
              data: (customers) {
                return DropdownButtonFormField<String>(
                  value: _selectedCustomerId,
                  decoration: const InputDecoration(
                    labelText: 'العميل',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  items: customers.map<DropdownMenuItem<String>>((customer) {
                    return DropdownMenuItem<String>(
                      value: customer['id'].toString(),
                      child: Text(customer['name'] ?? 'بدون اسم'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCustomerId = value);
                  },
                  validator: (value) => value == null ? 'مطلوب' : null,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Text('خطأ في تحميل العملاء'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'التاريخ',
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
                      TextFormField(
                        initialValue: line.description,
                        decoration: const InputDecoration(
                          labelText: 'الوصف',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _updateLine(index, 'description', value),
                        validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: line.quantity.toString(),
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
                        'الإجمالي: ${line.lineTotal.toStringAsFixed(2)}',
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
                    const Text('إجمالي أمر البيع:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  : const Text('حفظ أمر البيع', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
