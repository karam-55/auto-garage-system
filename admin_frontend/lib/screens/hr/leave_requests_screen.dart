import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/erp_providers.dart';
import 'models/leave_request.dart';
import 'create_leave_request_screen.dart';

class LeaveRequestsScreen extends ConsumerStatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  ConsumerState<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends ConsumerState<LeaveRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(leaveRequestsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(leaveRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات الإجازة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(leaveRequestsProvider),
          ),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات إجازة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(leaveRequestsProvider),
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('طلب إجازة رقم: ${request.id}'),
                    subtitle: Text(
                      'الموظف: ${request.userId} - النوع: ${_getLeaveTypeText(request.leaveType)} - الحالة: ${_getStatusText(request.status)}',
                    ),
                    trailing: _buildStatusIcon(request.status),
                    onTap: () => _showRequestDetails(context, request),
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
                onPressed: () => ref.refresh(leaveRequestsProvider),
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
              builder: (context) => const CreateLeaveRequestScreen(),
            ),
          ).then((result) {
            if (result == true) {
              ref.refresh(leaveRequestsProvider);
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
      case 'approved':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  void _showRequestDetails(BuildContext context, LeaveRequest request) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تفاصيل طلب الإجازة رقم ${request.id}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الموظف: ${request.userId}'),
            const SizedBox(height: 8),
            Text('نوع الإجازة: ${_getLeaveTypeText(request.leaveType)}'),
            const SizedBox(height: 8),
            Text('تاريخ البدء: ${_formatDate(request.startDate)}'),
            const SizedBox(height: 8),
            Text('تاريخ الانتهاء: ${_formatDate(request.endDate)}'),
            const SizedBox(height: 8),
            Text('الحالة: ${_getStatusText(request.status)}'),
            const SizedBox(height: 8),
            if (request.approvedBy != null) Text('الموافق: ${request.approvedBy}'),
            const SizedBox(height: 8),
            if (request.approvedAt != null) Text('تاريخ الموافقة: ${_formatDate(request.approvedAt!)}'),
            const SizedBox(height: 8),
            if (request.reason != null) Text('السبب: ${request.reason}'),
          ],
        ),
        actions: [
          if (request.status == 'pending')
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final approvedBy = 'المستخدم الحالي'; // TODO: Get from auth
                    try {
                      await ref.read(approveLeaveRequestProvider((id: request.id, approvedBy: approvedBy)).future);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ref.refresh(leaveRequestsProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تمت الموافقة على طلب الإجازة')),
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
                  label: const Text('موافقة'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    try {
                      await ref.read(rejectLeaveRequestProvider(request.id).future);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ref.refresh(leaveRequestsProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم رفض طلب الإجازة')),
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
                  icon: const Icon(Icons.cancel),
                  label: const Text('رفض'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: تعديل طلب الإجازة')),
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
                  content: const Text('هل أنت متأكد من حذف طلب الإجازة؟'),
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
                  await ref.read(deleteLeaveRequestProvider(request.id).future);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(leaveRequestsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف طلب الإجازة')),
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
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String _getLeaveTypeText(String type) {
    switch (type) {
      case 'annual':
        return 'إجازة سنوية';
      case 'sick':
        return 'إجازة مرضية';
      case 'unpaid':
        return 'إجازة بدون راتب';
      case 'maternity':
        return 'إجازة أمومة';
      case 'paternity':
        return 'إجازة أبوة';
      default:
        return type;
    }
  }
}
