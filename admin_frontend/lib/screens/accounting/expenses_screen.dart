import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/financial_providers.dart';
import '../../core/providers/accounting_providers.dart';
import '../../core/services/api_service.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const ExpensesScreen({super.key, required this.apiService});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصاريف التشغيلية'),
      ),
      body: ref.watch(expensesProvider).when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مصاريف',
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
              DataColumn(label: Text('التاريخ')),
              DataColumn(label: Text('الحساب')),
              DataColumn(label: Text('المبلغ')),
              DataColumn(label: Text('الوصف')),
              DataColumn(label: Text('طريقة الدفع')),
              DataColumn(label: Text('')),
            ],
            rows: expenses.map<DataRow>((expense) {
              return DataRow(cells: [
                DataCell(Text(expense['expense_date']?.toString() ?? '-')),
                DataCell(Text(expense['account_id'].toString())),
                DataCell(Text((expense['amount'] as num).toStringAsFixed(2))),
                DataCell(Text(expense['description']?.toString() ?? '-')),
                DataCell(Text(expense['payment_method']?.toString() ?? '-')),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteExpense(expense['id'] as int),
                    tooltip: 'حذف',
                  ),
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
        onPressed: _addExpense,
        child: const Icon(Icons.add),
        tooltip: 'إضافة مصروف',
      ),
    );
  }

  Future<void> _addExpense() async {
    final dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final paymentMethodController = TextEditingController(text: 'cash');

    // Get accounts for dropdown
    final accounts = await ref.read(accountsProvider.future);

    if (!mounted) return;

    int? selectedAccountId;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة مصروف'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'حساب المصروف',
                    border: OutlineInputBorder(),
                  ),
                  items: (accounts as List).map<DropdownMenuItem<int>>((account) {
                    return DropdownMenuItem<int>(
                      value: account['id'] as int,
                      child: Text(account['name_ar'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedAccountId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'التاريخ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 16),
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
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: paymentMethodController,
                  decoration: const InputDecoration(
                    labelText: 'طريقة الدفع',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    if (selectedAccountId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار حساب المصروف')),
        );
      }
      return;
    }

    try {
      await ref.read(createExpenseProvider({
        'expense_date': dateController.text,
        'account_id': selectedAccountId,
        'amount': double.parse(amountController.text),
        'description': descriptionController.text,
        'payment_method': paymentMethodController.text,
      }).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المصروف بنجاح')),
        );
      }

      ref.invalidate(expensesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }

    dateController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    paymentMethodController.dispose();
  }

  Future<void> _deleteExpense(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
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

    if (confirmed != true) return;

    try {
      await ref.read(deleteExpenseProvider(id).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المصروف بنجاح')),
        );
      }
      ref.invalidate(expensesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حذف المصروف: $e')),
        );
      }
    }
  }
}
