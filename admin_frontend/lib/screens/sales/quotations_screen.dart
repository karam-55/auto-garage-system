import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_localizations.dart';
import '../../core/providers/erp_providers.dart';
import 'models/quotation.dart';
import 'create_quotation_screen.dart';

class QuotationsScreen extends ConsumerStatefulWidget {
  const QuotationsScreen({super.key});

  @override
  ConsumerState<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends ConsumerState<QuotationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(quotationsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quotationsAsync = ref.watch(quotationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عروض الأسعار'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(quotationsProvider),
          ),
        ],
      ),
      body: quotationsAsync.when(
        data: (quotations) {
          if (quotations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد عروض أسعار',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(quotationsProvider.future);
            },
            child: ListView.builder(
              itemCount: quotations.length,
              itemBuilder: (context, index) {
                final quotation = quotations[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('عرض سعر رقم: ${quotation.quotationNumber}'),
                    subtitle: Text(
                      'التاريخ: ${_formatDate(quotation.date)} - الحالة: ${_getStatusText(quotation.status)}',
                    ),
                    trailing: Text('${quotation.totalAmount.toStringAsFixed(2)} ل.س'),
                    onTap: () => _showQuotationDetails(context, quotation),
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
                onPressed: () => ref.refresh(quotationsProvider),
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
              builder: (context) => const CreateQuotationScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(quotationsProvider);
            }
          });
        },
      ),
    );
  }

  void _showQuotationDetails(BuildContext context, Quotation quotation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل عرض السعر ${quotation.quotationNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('رقم العميل: ${quotation.customerId}'),
              const SizedBox(height: 8),
              Text('التاريخ: ${_formatDate(quotation.date)}'),
              const SizedBox(height: 8),
              Text('صالح حتى: ${quotation.validUntil != null ? _formatDate(quotation.validUntil!) : 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('الحالة: ${_getStatusText(quotation.status)}'),
              const SizedBox(height: 8),
              Text('المبلغ الإجمالي: ${quotation.totalAmount.toStringAsFixed(2)} ل.س'),
              const SizedBox(height: 8),
              if (quotation.notes != null) Text('ملاحظات: ${quotation.notes}'),
              const SizedBox(height: 16),
              const Text('الأصناف:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...quotation.lines.map((line) => Padding(
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
          if (quotation.status == 'draft' || quotation.status == 'sent')
            TextButton.icon(
              onPressed: () async {
                try {
                  await ref.read(convertQuotationToOrderProvider(quotation.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(quotationsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحويل العرض إلى أمر بيع')),
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
              icon: const Icon(Icons.shopping_cart),
              label: const Text('تحويل لأمر بيع'),
            ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل عرض السعر')),
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
                  content: const Text('هل أنت متأكد من حذف عرض السعر؟'),
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
                  await ref.read(deleteQuotationProvider(quotation.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(quotationsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف عرض السعر')),
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
      case 'draft':
        return 'مسودة';
      case 'sent':
        return 'مرسل';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'expired':
        return 'منتهي';
      default:
        return status;
    }
  }
}
