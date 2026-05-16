import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';
import '../../presentation/providers/inventory_provider.dart';

class ConsumePartScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const ConsumePartScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ConsumePartScreen> createState() => _ConsumePartScreenState();
}

class _ConsumePartScreenState extends ConsumerState<ConsumePartScreen> {
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, int> _selectedQuantities = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(inventoryStateProvider.notifier).fetchInventory();
    });
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _consumePart(String variantId, int quantity, String itemName) async {
    if (quantity <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الكمية يجب أن تكون أكبر من صفر')),
        );
      }
      return;
    }

    try {
      await ref.read(inventoryStateProvider.notifier).consumePart(
            variantId,
            quantity,
            widget.bookingId,
          );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم استهلاك $quantity من $itemName بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في استهلاك القطعة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استهلاك قطع من المخزون'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final inventoryState = ref.watch(inventoryStateProvider);
          
          if (inventoryState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (inventoryState.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(inventoryState.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(inventoryStateProvider.notifier).fetchInventory();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (inventoryState.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('المخزون فارغ أو لا توجد قطع متاحة'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(inventoryStateProvider.notifier).fetchInventory();
            },
            child: ListView.builder(
              itemCount: inventoryState.items.length,
              itemBuilder: (context, index) {
                final item = inventoryState.items[index];
                return _buildInventoryItemCard(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryItemCard(InventoryItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('التصنيف: ${item.category}'),
            const SizedBox(height: 8),
            ...item.variants.where((variant) => variant.isAvailable).map((variant) {
              final variantId = variant.id;
              if (!_quantityControllers.containsKey(variantId)) {
                _quantityControllers[variantId] = TextEditingController(text: '0');
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text('المتغير: ${variant.name ?? 'غير محدد'}'),
                  const SizedBox(height: 4),
                  Text('الكمية المتاحة: ${variant.quantity}'),
                  const SizedBox(height: 4),
                  Text('السعر: ${variant.priceSYP} ل.س'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('الكمية المستهلكة: '),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _quantityControllers[variantId],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '0',
                          ),
                          onChanged: (value) {
                            final qty = int.tryParse(value) ?? 0;
                            _selectedQuantities[variantId] = qty;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          final quantity = _selectedQuantities[variantId] ?? 0;
                          if (quantity > variant.quantity) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('الكمية المطلوبة ($quantity) أكبر من المتاحة (${variant.quantity})')),
                            );
                            return;
                          }
                          _consumePart(variantId, quantity, item.name);
                        },
                        child: const Text('تأكيد'),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
