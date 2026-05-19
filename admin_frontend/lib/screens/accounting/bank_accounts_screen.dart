import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/financial_providers.dart';
import '../../core/services/api_service.dart';

class BankAccountsScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const BankAccountsScreen({super.key, required this.apiService});

  @override
  ConsumerState<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends ConsumerState<BankAccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحسابات البنكية'),
      ),
      body: ref.watch(bankAccountsProvider).when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد حسابات بنكية',
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
              DataColumn(label: Text('اسم الحساب')),
              DataColumn(label: Text('رقم الحساب')),
              DataColumn(label: Text('البنك')),
              DataColumn(label: Text('الرصيد الحالي')),
              DataColumn(label: Text('الحالة')),
              DataColumn(label: Text('')),
            ],
            rows: accounts.map<DataRow>((account) {
              final isActive = account['is_active'] as bool;
              return DataRow(cells: [
                DataCell(Text(account['account_name'] as String)),
                DataCell(Text(account['account_number']?.toString() ?? '-')),
                DataCell(Text(account['bank_name']?.toString() ?? '-')),
                DataCell(Text((account['current_balance'] as num).toStringAsFixed(2))),
                DataCell(
                  Chip(
                    label: Text(isActive ? 'نشط' : 'غير نشط'),
                    backgroundColor: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () => _reconcileAccount(account['id'] as int),
                    tooltip: 'تسوية',
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
        onPressed: _addAccount,
        child: const Icon(Icons.add),
        tooltip: 'إضافة حساب بنكي',
      ),
    );
  }

  Future<void> _addAccount() async {
    final nameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final bankNameController = TextEditingController();
    final initialBalanceController = TextEditingController(text: '0');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة حساب بنكي'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الحساب',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'رقم الحساب',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bankNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم البنك',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: initialBalanceController,
                decoration: const InputDecoration(
                  labelText: 'الرصيد الأولي',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
    );

    if (result != true) return;

    try {
      await ref.read(createBankAccountProvider({
        'account_name': nameController.text,
        'account_number': accountNumberController.text,
        'bank_name': bankNameController.text,
        'initial_balance': double.parse(initialBalanceController.text),
      }).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الحساب بنجاح')),
        );
      }

      ref.invalidate(bankAccountsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }

    nameController.dispose();
    accountNumberController.dispose();
    bankNameController.dispose();
    initialBalanceController.dispose();
  }

  Future<void> _reconcileAccount(int accountId) async {
    // TODO: Navigate to bank reconciliation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ميزة التسوية البنكية قيد التطوير')),
    );
  }
}
