import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/sales_order.dart';
import 'create_sales_order_screen.dart';

class SalesOrdersScreen extends ConsumerStatefulWidget {
  const SalesOrdersScreen({super.key});

  @override
  ConsumerState<SalesOrdersScreen> createState() => _SalesOrdersScreenState();
}

class _SalesOrdersScreenState extends ConsumerState<SalesOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(salesOrdersProvider));
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(salesOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أوامر البيع'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(salesOrdersProvider),
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
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد أوامر بيع',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(salesOrdersProvider.future);
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('أمر بيع رقم: ${order.orderNumber}'),
                    subtitle: Text(
                      'التاريخ: ${_formatDate(order.orderDate)} - الحالة: ${_getStatusText(order.status)}',
                    ),
                    trailing: Text('${order.totalAmount.toStringAsFixed(2)} ل.س'),
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
                onPressed: () => ref.refresh(salesOrdersProvider),
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
              builder: (context) => const CreateSalesOrderScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(salesOrdersProvider);
            }
          });
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, SalesOrder order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل أمر البيع ${order.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('رقم العميل: ${order.customerId}'),
              const SizedBox(height: 8),
              Text('التاريخ: ${_formatDate(order.orderDate)}'),
              const SizedBox(height: 8),
              Text('تاريخ التسليم: ${order.deliveryDate != null ? _formatDate(order.deliveryDate!) : 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('الحالة: ${_getStatusText(order.status)}'),
              const SizedBox(height: 8),
              Text('المبلغ الإجمالي: ${order.totalAmount.toStringAsFixed(2)} ل.س'),
              const SizedBox(height: 8),
              if (order.notes != null) Text('ملاحظات: ${order.notes}'),
              const SizedBox(height: 16),
              const Text('الأصناف:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order.lines.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '- ${line.description ?? line.serviceId ?? line.inventoryVariantId ?? 'صنف'} | الكمية: ${line.quantity} | السعر: ${line.unitPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل أمر البيع')),
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
                  content: const Text('هل أنت متأكد من حذف أمر البيع؟'),
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
                  await ref.read(deleteSalesOrderProvider(order.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(salesOrdersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف أمر البيع')),
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
      case 'confirmed':
        return 'مؤكد';
      case 'shipped':
        return 'مشحون';
      case 'delivered':
        return 'مستلم';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
