import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_localizations.dart';
import '../../core/providers/erp_providers.dart';
import 'models/purchase_order.dart';
import 'create_purchase_order_screen.dart';

class PurchaseOrdersScreen extends ConsumerStatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  ConsumerState<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends ConsumerState<PurchaseOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data on load
    Future.microtask(() => ref.refresh(purchaseOrdersProvider));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(purchaseOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.purchaseOrders),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(purchaseOrdersProvider),
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
                    l10n.noPurchaseOrders,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(purchaseOrdersProvider.future);
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('أمر شراء رقم: ${order.orderNumber}'),
                    subtitle: Text(
                      'التاريخ: ${_formatDate(order.orderDate)} - الحالة: ${_getStatusText(order.status)}',
                    ),
                    trailing: Text('${order.lines.fold<double>(0, (sum, line) => sum + line.totalPrice).toStringAsFixed(2)} ل.س'),
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
                onPressed: () => ref.refresh(purchaseOrdersProvider),
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
              builder: (context) => const CreatePurchaseOrderScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(purchaseOrdersProvider);
            }
          });
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل أمر الشراء ${order.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('رقم المورد: ${order.vendorId}'),
              const SizedBox(height: 8),
              Text('التاريخ: ${_formatDate(order.orderDate)}'),
              const SizedBox(height: 8),
              Text('التاريخ المتوقع: ${order.expectedDate != null ? _formatDate(order.expectedDate!) : 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('الحالة: ${_getStatusText(order.status)}'),
              const SizedBox(height: 8),
              if (order.notes != null) Text('ملاحظات: ${order.notes}'),
              const SizedBox(height: 16),
              const Text('الأصناف:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order.lines.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '- صنف: ${line.inventoryVariantId} | الكمية: ${line.quantityOrdered}/${line.quantityReceived} | السعر: ${line.unitPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          if (order.status == 'pending')
            TextButton.icon(
              onPressed: () async {
                try {
                  await ref.read(confirmPurchaseOrderProvider(order.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(purchaseOrdersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تأكيد أمر الشراء')),
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
              label: const Text('تأكيد'),
            ),
          if (order.status == 'confirmed')
            TextButton.icon(
              onPressed: () async {
                final quantitiesController = TextEditingController();
                final quantities = <String, int>{};
                
                for (var line in order.lines) {
                  quantities[line.inventoryVariantId] = line.quantityOrdered - line.quantityReceived;
                }
                
                quantitiesController.text = quantities.entries.map((e) => '${e.key}:${e.value}').join(',');
                
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('استلام الطلب'),
                    content: TextField(
                      controller: quantitiesController,
                      decoration: const InputDecoration(
                        labelText: 'الكميات المستلمة (صنفID:كمية)',
                        helperText: 'مثال: item1:10,item2:5',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final parts = quantitiesController.text.split(',');
                            final receivedItems = <Map<String, dynamic>>[];
                            
                            for (var part in parts) {
                              final kv = part.split(':');
                              if (kv.length == 2) {
                                receivedItems.add({
                                  'inventoryVariantId': kv[0],
                                  'quantityReceived': int.parse(kv[1]),
                                });
                              }
                            }
                            
                            await ref.read(receivePurchaseOrderProvider(UpdateArgs(order.id, {'items': receivedItems})).future);
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              ref.refresh(purchaseOrdersProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم استلام الطلب')),
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
                        child: const Text('استلام'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.inventory),
              label: const Text('استلام'),
            ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل أمر الشراء')),
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
                  content: const Text('هل أنت متأكد من حذف أمر الشراء؟'),
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
                  await ref.read(deletePurchaseOrderProvider(order.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(purchaseOrdersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف أمر الشراء')),
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
      case 'partial':
        return 'استلام جزئي';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
