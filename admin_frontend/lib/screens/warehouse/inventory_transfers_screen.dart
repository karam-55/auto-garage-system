import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/inventory_transfer.dart';
import 'create_inventory_transfer_screen.dart';

class InventoryTransfersScreen extends ConsumerStatefulWidget {
  const InventoryTransfersScreen({super.key});

  @override
  ConsumerState<InventoryTransfersScreen> createState() => _InventoryTransfersScreenState();
}

class _InventoryTransfersScreenState extends ConsumerState<InventoryTransfersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(inventoryTransfersProvider));
  }

  @override
  Widget build(BuildContext context) {
    final transfersAsync = ref.watch(inventoryTransfersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('نقل المخزون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(inventoryTransfersProvider),
          ),
        ],
      ),
      body: transfersAsync.when(
        data: (transfers) {
          if (transfers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swap_horiz, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد عمليات نقل',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(inventoryTransfersProvider),
            child: ListView.builder(
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('نقل صنف: ${transfer.variantId}'),
                    subtitle: Text(
                      'من مستودع: ${transfer.fromWarehouseId} إلى: ${transfer.toWarehouseId} - الحالة: ${_getStatusText(transfer.status)}',
                    ),
                    trailing: Text('الكمية: ${transfer.quantity}'),
                    onTap: () => _showTransferDetails(context, transfer),
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
                onPressed: () => ref.refresh(inventoryTransfersProvider),
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
              builder: (context) => const CreateInventoryTransferScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(inventoryTransfersProvider);
            }
          });
        },
      ),
    );
  }

  void _showTransferDetails(BuildContext context, InventoryTransfer transfer) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تفاصيل عملية النقل'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الصنف: ${transfer.variantId}'),
            const SizedBox(height: 8),
            Text('من مستودع: ${transfer.fromWarehouseId}'),
            const SizedBox(height: 8),
            Text('إلى مستودع: ${transfer.toWarehouseId}'),
            const SizedBox(height: 8),
            Text('الكمية: ${transfer.quantity}'),
            const SizedBox(height: 8),
            Text('تاريخ النقل: ${_formatDate(transfer.transferDate)}'),
            const SizedBox(height: 8),
            Text('الحالة: ${_getStatusText(transfer.status)}'),
            const SizedBox(height: 8),
            if (transfer.notes != null) Text('ملاحظات: ${transfer.notes}'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل عملية النقل')),
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
                  content: const Text('هل أنت متأكد من حذف عملية النقل؟'),
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
                  await ref.read(deleteInventoryTransferProvider(transfer.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(inventoryTransfersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف عملية النقل')),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
