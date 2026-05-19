import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/employee_contract.dart';
import 'create_employee_contract_screen.dart';

class EmployeeContractsScreen extends ConsumerStatefulWidget {
  const EmployeeContractsScreen({super.key});

  @override
  ConsumerState<EmployeeContractsScreen> createState() => _EmployeeContractsScreenState();
}

class _EmployeeContractsScreenState extends ConsumerState<EmployeeContractsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(employeeContractsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(employeeContractsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عقود الموظفين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(employeeContractsProvider),
          ),
        ],
      ),
      body: contractsAsync.when(
        data: (contracts) {
          if (contracts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد عقود',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(employeeContractsProvider.future);
            },
            child: ListView.builder(
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                final contract = contracts[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('عقد رقم: ${contract.id}'),
                    subtitle: Text(
                      'الموظف: ${contract.userId} - النوع: ${_getContractTypeText(contract.contractType)}',
                    ),
                    trailing: contract.baseSalary != null
                        ? Text('${contract.baseSalary!.toStringAsFixed(2)} ل.س')
                        : null,
                    onTap: () => _showContractDetails(context, contract),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'خطأ: $err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(employeeContractsProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEmployeeContractScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(employeeContractsProvider);
            }
          });
        },
      ),
    );
  }

  void _showContractDetails(BuildContext context, EmployeeContract contract) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل العقد رقم ${contract.id}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الموظف: ${contract.userId}'),
            const SizedBox(height: 8),
            Text('نوع العقد: ${_getContractTypeText(contract.contractType)}'),
            const SizedBox(height: 8),
            Text('تاريخ البدء: ${_formatDate(contract.startDate)}'),
            const SizedBox(height: 8),
            Text('تاريخ الانتهاء: ${contract.endDate != null ? _formatDate(contract.endDate!) : 'غير محدد'}'),
            const SizedBox(height: 8),
            if (contract.baseSalary != null) Text('الراتب الأساسي: ${contract.baseSalary!.toStringAsFixed(2)} ل.س'),
            const SizedBox(height: 8),
            if (contract.benefits != null) Text('المزايا: ${contract.benefits}'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل العقد')),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('تعديل'),
          ),
          TextButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('تأكيد الحذف'),
                  content: const Text('هل أنت متأكد من حذف العقد؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && context.mounted) {
                try {
                  await ref.read(deleteEmployeeContractProvider(contract.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(employeeContractsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف العقد')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: $e')),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('حذف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  String _getContractTypeText(String type) {
    switch (type) {
      case 'full_time':
        return 'دوام كامل';
      case 'part_time':
        return 'دوام جزئي';
      case 'contract':
        return 'عقد';
      case 'intern':
        return 'تدريب';
      default:
        return type;
    }
  }
}
