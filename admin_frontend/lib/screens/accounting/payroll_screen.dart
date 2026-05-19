import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/payroll_providers.dart';
import '../../core/services/api_service.dart';

class PayrollScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const PayrollScreen({super.key, required this.apiService});

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen> {
  DateTime? _selectedMonth;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كشوف الرواتب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectMonth,
            tooltip: 'اختر الشهر',
          ),
          if (_selectedMonth != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedMonth = null;
                });
              },
              tooltip: 'مسح التصفية',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedMonth != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Chip(
                label: Text('${_selectedMonth!.month}/${_selectedMonth!.year}'),
                onDeleted: () {
                  setState(() {
                    _selectedMonth = null;
                  });
                },
              ),
            ),
          Expanded(
            child: _buildPayrollList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isGenerating ? null : _generatePayroll,
        child: _isGenerating
            ? const CircularProgressIndicator()
            : const Icon(Icons.add),
        tooltip: 'إنشاء كشف رواتب',
      ),
    );
  }

  Widget _buildPayrollList() {
    final monthYearStr = _selectedMonth != null
        ? '${_selectedMonth!.year}-${_selectedMonth!.month.toString().padLeft(2, '0')}-01'
        : null;

    return ref.watch(salaryListProvider(monthYearStr)).when(
      data: (payments) {
        if (payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _selectedMonth != null
                      ? 'لا توجد كشوف رواتب لهذا الشهر'
                      : 'لا توجد كشوف رواتب',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 8),
                const Text('اضغط على + لإنشاء كشف جديد'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('الموظف')),
              DataColumn(label: Text('الراتب الأساسي'), numeric: true),
              DataColumn(label: Text('أيام العمل'), numeric: true),
              DataColumn(label: Text('بدلات'), numeric: true),
              DataColumn(label: Text('استقطاعات'), numeric: true),
              DataColumn(label: Text('صافي الراتب'), numeric: true),
              DataColumn(label: Text('الحالة')),
              DataColumn(label: Text('')),
            ],
            rows: payments.map<DataRow>((payment) {
              return DataRow(cells: [
                DataCell(Text(payment['user_id'] as String)),
                DataCell(Text((payment['base_salary'] as num).toStringAsFixed(2))),
                DataCell(Text(payment['working_days'].toString())),
                DataCell(Text((payment['bonuses'] as num).toStringAsFixed(2))),
                DataCell(Text((payment['deductions'] as num).toStringAsFixed(2))),
                DataCell(Text((payment['net_salary'] as num).toStringAsFixed(2))),
                DataCell(
                  Chip(
                    label: Text(payment['is_paid'] ? 'مدفوع' : 'غير مدفوع'),
                    backgroundColor: payment['is_paid'] ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  ),
                ),
                DataCell(
                  payment['is_paid']
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : IconButton(
                        icon: const Icon(Icons.payment),
                        onPressed: () => _paySalary(payment['id'] as int),
                        tooltip: 'صرف الراتب',
                      ),
                ),
              ]);
            }).toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('خطأ في تحميل البيانات: $error'),
          ],
        ),
      ),
    );
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month, 1),
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Future<void> _generatePayroll() async {
    final monthYear = _selectedMonth ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    
    setState(() {
      _isGenerating = true;
    });

    try {
      // Get employees with base_salary > 0
      final employees = await widget.apiService.get('/users');
      final employeesWithSalary = (employees as List)
          .where((e) => ((e['base_salary'] as num?)?.toDouble() ?? 0) > 0)
          .toList();

      if (employeesWithSalary.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يوجد موظفين براتب محدد')),
          );
        }
        return;
      }

      await ref.read(generatePayrollProvider({
        'month_year': monthYear.toIso8601String(),
        'employees': employeesWithSalary,
      }).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء كشف الرواتب بنجاح')),
        );
      }

      // Refresh list
      ref.invalidate(salaryListProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إنشاء كشف الرواتب: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _paySalary(int salaryPaymentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد صرف الراتب'),
        content: const Text('هل أنت متأكد من صرف هذا الراتب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(paySalaryProvider(salaryPaymentId).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم صرف الراتب بنجاح')),
        );
      }

      // Refresh list
      ref.invalidate(salaryListProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في صرف الراتب: $e')),
        );
      }
    }
  }
}
