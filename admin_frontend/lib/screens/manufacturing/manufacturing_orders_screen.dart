import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/manufacturing_order.dart';
import 'create_manufacturing_order_screen.dart';

class ManufacturingOrdersScreen extends ConsumerStatefulWidget {
  const ManufacturingOrdersScreen({super.key});

  @override
  ConsumerState<ManufacturingOrdersScreen> createState() => _ManufacturingOrdersScreenState();
}

class _ManufacturingOrdersScreenState extends ConsumerState<ManufacturingOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(manufacturingOrdersProvider));
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(manufacturingOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أوامر الإنتاج'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(manufacturingOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.precision_manufacturing, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد أوامر إنتاج',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(manufacturingOrdersProvider),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('أمر إنتاج رقم: ${order.id}'),
                    subtitle: Text(
                      'الكمية المطلوبة: ${order.quantityToProduce} - المنتج: ${order.producedQuantity} - الحالة: ${_getStatusText(order.status)}',
                    ),
                    trailing: _buildStatusIcon(order.status),
                    onTap: () => _showOrderDetails(context, order),
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
                onPressed: () => ref.refresh(manufacturingOrdersProvider),
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
              builder: (context) => const CreateManufacturingOrderScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(manufacturingOrdersProvider);
            }
          });
        },
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.pending, color: Colors.orange);
      case 'in_progress':
        return const Icon(Icons.play_arrow, color: Colors.blue);
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  void _showOrderDetails(BuildContext context, ManufacturingOrder order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل أمر الإنتاج رقم ${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('رقم قائمة المواد: ${order.bomId}'),
              const SizedBox(height: 8),
              Text('الكمية المطلوبة: ${order.quantityToProduce}'),
              const SizedBox(height: 8),
              Text('الكمية المنتجة: ${order.producedQuantity}'),
              const SizedBox(height: 8),
              Text('تاريخ البدء: ${order.startDate != null ? _formatDate(order.startDate!) : 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('تاريخ الانتهاء: ${order.endDate != null ? _formatDate(order.endDate!) : 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('الحالة: ${_getStatusText(order.status)}'),
              const SizedBox(height: 8),
              if (order.notes != null) Text('ملاحظات: ${order.notes}'),
            ],
          ),
        ),
        actions: [
          if (order.status == 'in_progress')
            TextButton.icon(
              onPressed: () async {
                try {
                  await ref.read(completeManufacturingOrderProvider(order.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(manufacturingOrdersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إكمال أمر الإنتاج بنجاح')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('إكمال الأمر'),
            ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل أمر الإنتاج')),
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
                  content: const Text('هل أنت متأكد من حذف أمر الإنتاج؟'),
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
                  await ref.read(deleteManufacturingOrderProvider(order.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(manufacturingOrdersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف أمر الإنتاج')),
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
      case 'in_progress':
        return 'جاري التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
