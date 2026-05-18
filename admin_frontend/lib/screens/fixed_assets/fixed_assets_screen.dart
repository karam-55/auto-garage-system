import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/fixed_asset.dart';
import 'create_fixed_asset_screen.dart';

class FixedAssetsScreen extends ConsumerStatefulWidget {
  const FixedAssetsScreen({super.key});

  @override
  ConsumerState<FixedAssetsScreen> createState() => _FixedAssetsScreenState();
}

class _FixedAssetsScreenState extends ConsumerState<FixedAssetsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(fixedAssetsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(fixedAssetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأصول الثابتة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(fixedAssetsProvider),
          ),
        ],
      ),
      body: assetsAsync.when(
        data: (assets) {
          if (assets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد أصول ثابتة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(fixedAssetsProvider),
            child: ListView.builder(
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(asset.name),
                    subtitle: Text(
                      'التاريخ: ${_formatDate(asset.acquisitionDate)} - الحالة: ${_getStatusText(asset.status)}',
                    ),
                    trailing: Text('${asset.currentNetBookValue?.toStringAsFixed(2) ?? asset.acquisitionCost.toStringAsFixed(2)} ل.س'),
                    onTap: () => _showAssetDetails(context, asset),
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
                onPressed: () => ref.refresh(fixedAssetsProvider),
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
              builder: (context) => const CreateFixedAssetScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(fixedAssetsProvider);
            }
          });
        },
      ),
    );
  }

  void _showAssetDetails(BuildContext context, FixedAsset asset) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل الأصل الثابت ${asset.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تاريخ الشراء: ${_formatDate(asset.acquisitionDate)}'),
              const SizedBox(height: 8),
              Text('تكلفة الشراء: ${asset.acquisitionCost.toStringAsFixed(2)} ل.س'),
              const SizedBox(height: 8),
              Text('قيمة الخردة: ${asset.salvageValue.toStringAsFixed(2)} ل.س'),
              const SizedBox(height: 8),
              Text('العمر الافتراضي: ${asset.usefulLifeYears} سنة'),
              const SizedBox(height: 8),
              Text('طريقة الإهلاك: ${_getDepreciationMethodText(asset.depreciationMethod)}'),
              const SizedBox(height: 8),
              Text('القيمة الدفترية الحالية: ${asset.currentNetBookValue?.toStringAsFixed(2) ?? 'غير محدد'} ل.س'),
              const SizedBox(height: 8),
              Text('الموقع: ${asset.location ?? 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('الحالة: ${_getStatusText(asset.status)}'),
              const SizedBox(height: 16),
              const Text('إهلاكات:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...asset.depreciationEntries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '- ${_formatDate(entry.period)} | المبلغ: ${entry.depreciationAmount.toStringAsFixed(2)} ل.س',
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
                const SnackBar(content: Text('قريباً: تعديل الأصل الثابت')),
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
                  content: const Text('هل أنت متأكد من حذف الأصل الثابت؟'),
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
                  await ref.read(deleteFixedAssetProvider(asset.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(fixedAssetsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف الأصل الثابت')),
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
      case 'active':
        return 'نشط';
      case 'disposed':
        return 'مباع';
      case 'depreciated':
        return 'مهلك';
      default:
        return status;
    }
  }

  String _getDepreciationMethodText(String method) {
    switch (method) {
      case 'straight_line':
        return 'القسط الثابت';
      case 'declining_balance':
        return 'القسط المتناقص';
      case 'units_of_production':
        return 'وحدات الإنتاج';
      default:
        return method;
    }
  }
}
