import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/maintenance_contract.dart';
import 'create_maintenance_contract_screen.dart';

class MaintenanceContractsScreen extends ConsumerStatefulWidget {
  const MaintenanceContractsScreen({super.key});

  @override
  ConsumerState<MaintenanceContractsScreen> createState() => _MaintenanceContractsScreenState();
}

class _MaintenanceContractsScreenState extends ConsumerState<MaintenanceContractsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(maintenanceContractsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(maintenanceContractsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عقود الصيانة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(maintenanceContractsProvider),
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
                  Icon(Icons.build, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد عقود صيانة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(maintenanceContractsProvider.future);
            },
            child: ListView.builder(
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                final contract = contracts[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('عقد صيانة رقم: ${contract.id}'),
                    subtitle: Text(
                      'العميل: ${contract.customerId} - السيارة: ${contract.vehicleId} - الحالة: ${_getStatusText(contract)}',
                    ),
                    trailing: Icon(
                      _isDueSoon(contract) ? Icons.warning : Icons.check_circle,
                      color: _isDueSoon(contract) ? Colors.orange : Colors.green,
                    ),
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
                onPressed: () => ref.refresh(maintenanceContractsProvider),
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
              builder: (context) => const CreateMaintenanceContractScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(maintenanceContractsProvider);
            }
          });
        },
      ),
    );
  }

  bool _isDueSoon(MaintenanceContract contract) {
    if (contract.nextServiceDue == null) return false;
    final daysUntilDue = contract.nextServiceDue!.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7 && daysUntilDue >= 0;
  }

  String _getStatusText(MaintenanceContract contract) {
    final now = DateTime.now();
    if (contract.endDate.isBefore(now)) {
      return 'منتهي';
    } else if (contract.startDate.isAfter(now)) {
      return 'قادم';
    } else if (_isDueSoon(contract)) {
      return 'قريب الاستحقاق';
    } else {
      return 'نشط';
    }
  }

  void _showContractDetails(BuildContext context, MaintenanceContract contract) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل عقد الصيانة رقم ${contract.id}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('العميل: ${contract.customerId}'),
            const SizedBox(height: 8),
            Text('السيارة: ${contract.vehicleId}'),
            const SizedBox(height: 8),
            Text('رقم العقد: ${contract.contractNumber ?? 'غير محدد'}'),
            const SizedBox(height: 8),
            Text('تاريخ البدء: ${_formatDate(contract.startDate)}'),
            const SizedBox(height: 8),
            Text('تاريخ الانتهاء: ${_formatDate(contract.endDate)}'),
            const SizedBox(height: 8),
            if (contract.serviceIntervalKm != null) Text('فترة الصيانة (كم): ${contract.serviceIntervalKm} كم'),
            const SizedBox(height: 8),
            if (contract.serviceIntervalDays != null) Text('فترة الصيانة (أيام): ${contract.serviceIntervalDays} يوم'),
            const SizedBox(height: 8),
            if (contract.lastServiceKm != null) Text('آخر صيانة (كم): ${contract.lastServiceKm} كم'),
            const SizedBox(height: 8),
            Text('تاريخ الصيانة التالية: ${contract.nextServiceDue != null ? _formatDate(contract.nextServiceDue!) : 'غير محدد'}'),
            const SizedBox(height: 8),
            if (contract.notes != null) Text('ملاحظات: ${contract.notes}'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل عقد الصيانة')),
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
                  content: const Text('هل أنت متأكد من حذف عقد الصيانة؟'),
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
                  await ref.read(deleteMaintenanceContractProvider(contract.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(maintenanceContractsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف عقد الصيانة')),
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
}
