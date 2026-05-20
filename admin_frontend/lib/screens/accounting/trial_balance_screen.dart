import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/report_providers.dart';
import '../../core/services/api_service.dart';

class TrialBalanceScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const TrialBalanceScreen({super.key, required this.apiService});

  @override
  ConsumerState<TrialBalanceScreen> createState() => _TrialBalanceScreenState();
}

class _TrialBalanceScreenState extends ConsumerState<TrialBalanceScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ميزان المراجعة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: 'اختر نطاق التاريخ',
          ),
          if (_fromDate != null || _toDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _fromDate = null;
                  _toDate = null;
                });
              },
              tooltip: 'مسح التصفية',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_fromDate != null || _toDate != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Chip(
                label: Text(
                  'من ${_fromDate?.toLocal().toString().split(' ')[0]} إلى ${_toDate?.toLocal().toString().split(' ')[0]}',
                ),
                onDeleted: () {
                  setState(() {
                    _fromDate = null;
                    _toDate = null;
                  });
                },
              ),
            ),
          Expanded(
            child: _buildTrialBalance(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialBalance() {
    final params = <String, String?>{
      'from': _fromDate?.toIso8601String(),
      'to': _toDate?.toIso8601String(),
    };

    return ref.watch(trialBalanceProvider(params)).when(
      data: (data) {
        if (data == null || data.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا توجد بيانات متاحة'),
              ],
            ),
          );
        }

        final lines = data['lines'] as List<dynamic>? ?? [];
        if (lines.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا توجد قيود يومية في النظام'),
                SizedBox(height: 8),
                Text('أضف قيود يومية أولاً لعرض ميزان المراجعة'),
              ],
            ),
          );
        }

        double totalDebit = 0;
        double totalCredit = 0;

        try {
          for (final line in lines) {
            if (line is Map<String, dynamic>) {
              totalDebit += (line['totalDebit'] as num?)?.toDouble() ?? 0;
              totalCredit += (line['totalCredit'] as num?)?.toDouble() ?? 0;
            }
          }
        } catch (e) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('خطأ في معالجة البيانات: $e'),
              ],
            ),
          );
        }

        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('رقم الحساب')),
                  DataColumn(label: Text('اسم الحساب')),
                  DataColumn(label: Text('مدين'), numeric: true),
                  DataColumn(label: Text('دائن'), numeric: true),
                ],
                rows: lines.map<DataRow>((line) {
                  if (line is! Map<String, dynamic>) {
                    return const DataRow(cells: [
                      DataCell(Text('-')),
                      DataCell(Text('خطأ في البيانات')),
                      DataCell(Text('-')),
                      DataCell(Text('-')),
                    ]);
                  }

                  final account = line['account'] as Map<String, dynamic>?;
                  if (account == null) {
                    return const DataRow(cells: [
                      DataCell(Text('-')),
                      DataCell(Text('حساب غير موجود')),
                      DataCell(Text('-')),
                      DataCell(Text('-')),
                    ]);
                  }

                  return DataRow(cells: [
                    DataCell(Text(account['code']?.toString() ?? '-')),
                    DataCell(Text(account['nameAr']?.toString() ?? '-')),
                    DataCell(Text((line['totalDebit'] as num?)?.toStringAsFixed(2) ?? '0.00')),
                    DataCell(Text((line['totalCredit'] as num?)?.toStringAsFixed(2) ?? '0.00')),
                  ]);
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي المدين: ${totalDebit.toStringAsFixed(2)}'),
                  Text('إجمالي الدائن: ${totalCredit.toStringAsFixed(2)}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (totalDebit - totalCredit).abs() < 0.01
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (totalDebit - totalCredit).abs() < 0.01
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الفرق:'),
                    Text(
                      ((totalDebit - totalCredit).abs() < 0.01
                              ? '0.00'
                              : (totalDebit - totalCredit).toStringAsFixed(2)),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (totalDebit - totalCredit).abs() < 0.01
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('خطأ في تحميل البيانات'),
            const SizedBox(height: 8),
            Text(error.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }
}
