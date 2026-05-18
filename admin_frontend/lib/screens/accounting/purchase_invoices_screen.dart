import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/financial_providers.dart';
import '../../core/services/api_service.dart';

class PurchaseInvoicesScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const PurchaseInvoicesScreen({super.key, required this.apiService});

  @override
  ConsumerState<PurchaseInvoicesScreen> createState() => _PurchaseInvoicesScreenState();
}

class _PurchaseInvoicesScreenState extends ConsumerState<PurchaseInvoicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فواتير الشراء'),
      ),
      body: ref.watch(purchaseInvoicesProvider).when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد فواتير شراء',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return DataTable(
            columns: const [
              DataColumn(label: Text('رقم الفاتورة')),
              DataColumn(label: Text('المورد')),
              DataColumn(label: Text('تاريخ الإصدار')),
              DataColumn(label: Text('الإجمالي')),
              DataColumn(label: Text('المدفوع')),
              DataColumn(label: Text('الحالة')),
              DataColumn(label: Text('')),
            ],
            rows: invoices.map<DataRow>((invoice) {
              final totalAmount = (invoice['total_amount'] as num).toDouble();
              final paidAmount = (invoice['paid_amount'] as num).toDouble();
              final status = invoice['status'] as String;
              final isPaid = status == 'paid';

              return DataRow(cells: [
                DataCell(Text(invoice['invoice_number'] as String)),
                DataCell(Text(invoice['vendor_id'].toString())),
                DataCell(Text(invoice['issue_date']?.toString() ?? '-')),
                DataCell(Text(totalAmount.toStringAsFixed(2))),
                DataCell(Text(paidAmount.toStringAsFixed(2))),
                DataCell(
                  Chip(
                    label: Text(status == 'paid' ? 'مدفوع' : status == 'partial' ? 'جزئي' : 'غير مدفوع'),
                    backgroundColor: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  ),
                ),
                DataCell(
                  if (!isPaid)
                    IconButton(
                      icon: const Icon(Icons.payment),
                      onPressed: () => _payInvoice(invoice),
                      tooltip: 'دفع',
                    )
                  else
                    const Icon(Icons.check_circle, color: Colors.green),
                ),
              ]);
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('خطأ في تحميل البيانات: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createInvoice,
        child: const Icon(Icons.add),
        tooltip: 'إضافة فاتورة شراء',
      ),
    );
  }

  Future<void> _createInvoice() async {
    // TODO: Navigate to create purchase invoice screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ميزة إنشاء فاتورة شراء قيد التطوير')),
    );
  }

  Future<void> _payInvoice(Map<String, dynamic> invoice) async {
    final totalAmount = (invoice['total_amount'] as num).toDouble();
    final paidAmount = (invoice['paid_amount'] as num).toDouble();
    final remainingAmount = totalAmount - paidAmount;

    final amountController = TextEditingController(text: remainingAmount.toStringAsFixed(2));
    final dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('دفع فاتورة شراء'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'تاريخ الدفع',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      await ref.read(payPurchaseInvoiceProvider({
        'id': invoice['id'],
        'data': {
          'payment_amount': double.parse(amountController.text),
          'payment_date': dateController.text,
        },
      }).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم دفع الفاتورة بنجاح')),
        );
      }

      ref.invalidate(purchaseInvoicesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في دفع الفاتورة: $e')),
        );
      }
    }

    amountController.dispose();
    dateController.dispose();
  }
}
