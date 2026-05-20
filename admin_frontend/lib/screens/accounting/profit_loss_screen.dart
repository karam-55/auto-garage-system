import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/report_providers.dart';
import '../../core/services/api_service.dart';

class ProfitLossScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const ProfitLossScreen({super.key, required this.apiService});

  @override
  ConsumerState<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends ConsumerState<ProfitLossScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الدخل'),
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
            child: _buildProfitLoss(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitLoss() {
    final params = <String, String?>{
      'from': _fromDate?.toIso8601String(),
      'to': _toDate?.toIso8601String(),
    };

    return ref.watch(profitLossProvider(params)).when(
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

        final revenues = data['revenues'] as List<dynamic>? ?? [];
        final expenses = data['expenses'] as List<dynamic>? ?? [];
        final totalRevenue = data['totalRevenue'] as num? ?? 0;
        final totalExpense = data['totalExpense'] as num? ?? 0;
        final netProfit = data['netProfit'] as num? ?? 0;

        if (revenues.isEmpty && expenses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا توجد بيانات للإيرادات والمصروفات'),
                SizedBox(height: 8),
                Text('أضف قيود يومية أولاً لعرض قائمة الدخل'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإيرادات',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (revenues.isEmpty)
                        const Text('لا توجد إيرادات')
                      else
                        ...revenues.map((item) {
                          final account = item['account'] as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(account['nameAr'] as String),
                                ),
                                Text(
                                  (item['amount'] as num).toStringAsFixed(2),
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي الإيرادات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            totalRevenue.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Expense Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المصروفات',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (expenses.isEmpty)
                        const Text('لا توجد مصروفات')
                      else
                        ...expenses.map((item) {
                          final account = item['account'] as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(account['nameAr'] as String),
                                ),
                                Text(
                                  (item['amount'] as num).toStringAsFixed(2),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي المصروفات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            totalExpense.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Net Profit Section
              Card(
                color: netProfit >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'صافي الربح',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${netProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: netProfit >= 0 ? Colors.green : Colors.red,
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
            Text('خطأ في تحميل البيانات: $error'),
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
