import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/crm_lead.dart';
import 'create_lead_screen.dart';

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(crmLeadsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(crmLeadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العملاء المحتملين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(crmLeadsProvider),
          ),
        ],
      ),
      body: leadsAsync.when(
        data: (leads) {
          if (leads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد عملاء محتملين',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(crmLeadsProvider.future);
            },
            child: ListView.builder(
              itemCount: leads.length,
              itemBuilder: (context, index) {
                final lead = leads[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('عميل محتمل رقم: ${lead.id}'),
                    subtitle: Text(
                      'المصدر: ${lead.source ?? 'غير محدد'} - الحالة: ${_getStatusText(lead.status)}${lead.estimatedValue != null ? ' - القيمة: ${lead.estimatedValue!.toStringAsFixed(2)} ل.س' : ''}',
                    ),
                    trailing: _buildStatusIcon(lead.status),
                    onTap: () => _showLeadDetails(context, lead),
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
                onPressed: () => ref.refresh(crmLeadsProvider),
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
              builder: (context) => const CreateLeadScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(crmLeadsProvider);
            }
          });
        },
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'new':
        return const Icon(Icons.add_circle, color: Colors.blue);
      case 'contacted':
        return const Icon(Icons.phone, color: Colors.orange);
      case 'qualified':
        return const Icon(Icons.star, color: Colors.yellow);
      case 'converted':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'lost':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  void _showLeadDetails(BuildContext context, CrmLead lead) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل العميل المحتمل رقم ${lead.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('العميل: ${lead.customerId ?? 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('المصدر: ${lead.source ?? 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('الحالة: ${_getStatusText(lead.status)}'),
              const SizedBox(height: 8),
              if (lead.estimatedValue != null) Text('القيمة المقدرة: ${lead.estimatedValue!.toStringAsFixed(2)} ل.س'),
              const SizedBox(height: 8),
              if (lead.closingDate != null) Text('تاريخ الإغلاق: ${_formatDate(lead.closingDate!)}'),
              const SizedBox(height: 8),
              if (lead.assignedTo != null) Text('المسؤول: ${lead.assignedTo}'),
              const SizedBox(height: 8),
              if (lead.notes != null) Text('ملاحظات: ${lead.notes}'),
              const SizedBox(height: 16),
              const Text('الأنشطة:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...lead.activities.map((activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '- ${activity.activityType} | ${activity.activityDate != null ? _formatDate(activity.activityDate) : 'غير محدد'}${activity.summary != null ? ': ${activity.summary}' : ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          if (lead.status != 'converted' && lead.status != 'lost')
            TextButton.icon(
              onPressed: () async {
                try {
                  await ref.read(convertLeadProvider(lead.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(crmLeadsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحويل العميل المحتمل بنجاح')),
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
              icon: const Icon(Icons.person_add),
              label: const Text('تحويل إلى عميل'),
            ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل العميل المحتمل')),
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
                  content: const Text('هل أنت متأكد من حذف العميل المحتمل؟'),
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
                  await ref.read(deleteCrmLeadProvider(lead.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(crmLeadsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف العميل المحتمل')),
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
      case 'new':
        return 'جديد';
      case 'contacted':
        return 'تم التواصل';
      case 'qualified':
        return 'مؤهل';
      case 'converted':
        return 'محول';
      case 'lost':
        return 'مفقود';
      default:
        return status;
    }
  }
}
