import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/payroll_providers.dart';
import '../../core/services/api_service.dart';

class PayrollReportScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const PayrollReportScreen({super.key, required this.apiService});

  @override
  ConsumerState<PayrollReportScreen> createState() => _PayrollReportScreenState();
}

class _PayrollReportScreenState extends ConsumerState<PayrollReportScreen> {
  DateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الرواتب'),
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
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _selectedMonth != null ? _printReport : null,
            tooltip: 'طباعة التقرير',
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
            child: _buildReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildReport() {
    if (_selectedMonth == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'اختر شهر لعرض تقرير الرواتب',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    final monthYearStr = '${_selectedMonth!.year}-${_selectedMonth!.month.toString().padLeft(2, '0')}-01';

    return ref.watch(payrollReportProvider(monthYearStr)).when(
      data: (report) {
        final payments = report['payments'] as List<dynamic>;
        final totalBaseSalary = report['total_base_salary'] as num;
        final totalBonuses = report['total_bonuses'] as num;
        final totalDeductions = report['total_deductions'] as num;
        final totalNetSalary = report['total_net_salary'] as num;
        final totalPaid = report['total_paid'] as int;
        final totalPending = report['total_pending'] as int;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملخص الشهر',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الشهر:'),
                          Text('${_selectedMonth!.month}/${_selectedMonth!.year}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('عدد الموظفين:'),
                          Text('${payments.length}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المدفوع:'),
                          Text('$totalPaid'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('غير المدفوع:'),
                          Text('$totalPending'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإجماليات المالية',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي الرواتب الأساسية:'),
                          Text(totalBaseSalary.toStringAsFixed(2)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي البدلات:'),
                          Text(totalBonuses.toStringAsFixed(2)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي الاستقطاعات:'),
                          Text(totalDeductions.toStringAsFixed(2)),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي صافي الرواتب:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            totalNetSalary.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل الرواتب',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('الموظف')),
                            DataColumn(label: Text('الراتب الأساسي'), numeric: true),
                            DataColumn(label: Text('أيام العمل'), numeric: true),
                            DataColumn(label: Text('بدلات'), numeric: true),
                            DataColumn(label: Text('استقطاعات'), numeric: true),
                            DataColumn(label: Text('صافي الراتب'), numeric: true),
                            DataColumn(label: Text('الحالة')),
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
                            ]);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
            Text('خطأ في تحميل التقرير: $error'),
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

  void _printReport() {
    // TODO: Implement PDF printing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ميزة الطباعة قيد التطوير')),
    );
  }
}
