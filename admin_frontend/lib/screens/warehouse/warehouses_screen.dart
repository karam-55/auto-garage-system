import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/warehouse.dart';
import 'create_warehouse_screen.dart';

class WarehousesScreen extends ConsumerStatefulWidget {
  const WarehousesScreen({super.key});

  @override
  ConsumerState<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends ConsumerState<WarehousesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(warehousesProvider));
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehousesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المستودعات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(warehousesProvider),
          ),
        ],
      ),
      body: warehousesAsync.when(
        data: (warehouses) {
          if (warehouses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warehouse, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مستودعات',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(warehousesProvider.future);
            },
            child: ListView.builder(
              itemCount: warehouses.length,
              itemBuilder: (context, index) {
                final warehouse = warehouses[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(warehouse.name),
                    subtitle: Text(
                      'الموقع: ${warehouse.location ?? 'غير محدد'} - الحالة: ${warehouse.isActive ? 'نشط' : 'غير نشط'}',
                    ),
                    trailing: Icon(
                      warehouse.isActive ? Icons.check_circle : Icons.cancel,
                      color: warehouse.isActive ? Colors.green : Colors.red,
                    ),
                    onTap: () => _showWarehouseDetails(context, warehouse),
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
                onPressed: () => ref.refresh(warehousesProvider),
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
              builder: (context) => const CreateWarehouseScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(warehousesProvider);
            }
          });
        },
      ),
    );
  }

  void _showWarehouseDetails(BuildContext context, Warehouse warehouse) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل المستودع ${warehouse.name}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الموقع: ${warehouse.location ?? 'غير محدد'}'),
            const SizedBox(height: 8),
            Text('الحالة: ${warehouse.isActive ? 'نشط' : 'غير نشط'}'),
            const SizedBox(height: 8),
            Text('تاريخ الإنشاء: ${_formatDate(warehouse.createdAt)}'),
            const SizedBox(height: 8),
            Text('تاريخ التحديث: ${_formatDate(warehouse.updatedAt)}'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل المستودع')),
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
                  content: const Text('هل أنت متأكد من حذف المستودع؟'),
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
                  await ref.read(deleteWarehouseProvider(warehouse.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(warehousesProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف المستودع')),
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
