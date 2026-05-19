import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/bill_of_materials.dart';
import 'create_bom_screen.dart';

class BomsScreen extends ConsumerStatefulWidget {
  const BomsScreen({super.key});

  @override
  ConsumerState<BomsScreen> createState() => _BomsScreenState();
}

class _BomsScreenState extends ConsumerState<BomsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(bomsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final bomsAsync = ref.watch(bomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('قوائم المواد (BOM)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(bomsProvider),
          ),
        ],
      ),
      body: bomsAsync.when(
        data: (boms) {
          if (boms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد قوائم مواد',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(bomsProvider.future);
            },
            child: ListView.builder(
              itemCount: boms.length,
              itemBuilder: (context, index) {
                final bom = boms[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(bom.name),
                    subtitle: Text(
                      'الإنتاج: ${bom.quantityOutput} - الحالة: ${bom.isActive ? 'نشط' : 'غير نشط'}',
                    ),
                    trailing: Icon(
                      bom.isActive ? Icons.check_circle : Icons.cancel,
                      color: bom.isActive ? Colors.green : Colors.red,
                    ),
                    onTap: () => _showBomDetails(context, bom),
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
                onPressed: () => ref.refresh(bomsProvider),
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
              builder: (context) => const CreateBomScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(bomsProvider);
            }
          });
        },
      ),
    );
  }

  void _showBomDetails(BuildContext context, BillOfMaterials bom) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل قائمة المواد ${bom.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الخدمة: ${bom.serviceId ?? 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('الإنتاج: ${bom.quantityOutput}'),
              const SizedBox(height: 8),
              Text('الحالة: ${bom.isActive ? 'نشط' : 'غير نشط'}'),
              const SizedBox(height: 16),
              const Text('الأصناف المطلوبة:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...bom.lines.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '- صنف: ${line.inputVariantId} | الكمية المطلوبة: ${line.quantityRequired} | التكلفة: ${line.unitCost.toStringAsFixed(2)}',
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
                const SnackBar(content: Text('قريباً: تعديل قائمة المواد')),
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
                  content: const Text('هل أنت متأكد من حذف قائمة المواد؟'),
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
                  await ref.read(deleteBomProvider(bom.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(bomsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف قائمة المواد')),
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
}
