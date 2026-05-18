import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/financial_providers.dart';
import '../../core/providers/account_providers.dart';
import '../../core/services/api_service.dart';

class BankReconciliationScreen extends ConsumerStatefulWidget {
  final ApiService apiService;
  final int bankAccountId;

  const BankReconciliationScreen({super.key, required this.apiService, required this.bankAccountId});

  @override
  ConsumerState<BankReconciliationScreen> createState() => _BankReconciliationScreenState();
}

class _BankReconciliationScreenState extends ConsumerState<BankReconciliationScreen> {
  final _statementDateController = TextEditingController();
  final _statementBalanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التسوية البنكية'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدخال بيانات كشف البنك',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _statementDateController,
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الكشف',
                        border: OutlineInputBorder(),
                        hintText: 'YYYY-MM-DD',
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _statementBalanceController,
                      decoration: const InputDecoration(
                        labelText: 'رصيد الكشف',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reconcile,
                      child: const Text('تسوية'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ref.watch(bankReconciliationProvider(widget.bankAccountId)).when(
              data: (reconciliations) {
                if (reconciliations.isEmpty) {
                  return const Center(
                    child: Text('لا توجد عمليات تسوية سابقة'),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عمليات التسوية السابقة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...reconciliations.map<Widget>((reconciliation) {
                          return ListTile(
                            title: Text('تاريخ الكشف: ${reconciliation['statement_date']}'),
                            subtitle: Text(
                              'رصيد الكشف: ${(reconciliation['statement_balance'] as num).toStringAsFixed(2)}\n'
                              'رصيد التسوية: ${(reconciliation['reconciled_balance'] as num).toStringAsFixed(2)}',
                            ),
                            trailing: Icon(
                              reconciliation['is_done'] ? Icons.check_circle : Icons.pending,
                              color: reconciliation['is_done'] ? Colors.green : Colors.orange,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('خطأ: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reconcile() async {
    if (_statementDateController.text.isEmpty || _statementBalanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال جميع البيانات')),
      );
      return;
    }

    try {
      final statementDate = DateTime.parse(_statementDateController.text);
      final statementBalance = double.parse(_statementBalanceController.text);

      await ref.read(reconcileBankAccountProvider({
        'id': widget.bankAccountId,
        'data': {
          'statement_date': _statementDateController.text,
          'statement_balance': statementBalance,
          'matched_journal_line_ids': [],
        },
      }).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت التسوية بنجاح')),
        );
      }

      ref.invalidate(bankReconciliationProvider(widget.bankAccountId));
      ref.invalidate(bankAccountsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التسوية: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _statementDateController.dispose();
    _statementBalanceController.dispose();
    super.dispose();
  }
}
