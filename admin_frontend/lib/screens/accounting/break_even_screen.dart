import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/report_providers.dart';

class BreakEvenScreen extends ConsumerStatefulWidget {
  const BreakEvenScreen({super.key});

  @override
  ConsumerState<BreakEvenScreen> createState() => _BreakEvenScreenState();
}

class _BreakEvenScreenState extends ConsumerState<BreakEvenScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل نقطة التعادل'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('من تاريخ'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectFromDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_fromDate.year}-${_fromDate.month.toString().padLeft(2, '0')}-${_fromDate.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('إلى تاريخ'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectToDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_toDate.year}-${_toDate.month.toString().padLeft(2, '0')}-${_toDate.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ref.watch(breakEvenProvider({'from': _fromDate, 'to': _toDate})).when(
              data: (data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard('إجمالي الإيرادات', data['totalRevenue'] as double, Colors.blue),
                    const SizedBox(height: 16),
                    _buildSummaryCard('إجمالي التكاليف المتغيرة', data['totalVariableCosts'] as double, Colors.orange),
                    const SizedBox(height: 16),
                    _buildSummaryCard('إجمالي التكاليف الثابتة', data['totalFixedCosts'] as double, Colors.red),
                    const SizedBox(height: 16),
                    _buildSummaryCard('هامش المساهمة', data['contributionMargin'] as double, Colors.purple),
                    const SizedBox(height: 16),
                    _buildSummaryCard('نسبة هامش المساهمة', (data['contributionMarginRatio'] as double) * 100, Colors.purple, isPercentage: true),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.green.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'نقطة التعادل',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              (data['breakEvenRevenue'] as double).toStringAsFixed(2),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
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
                child: Text('خطأ: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color, {bool isPercentage = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              isPercentage ? '${value.toStringAsFixed(2)}%' : value.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _fromDate = selected;
      });
    }
  }

  Future<void> _selectToDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _toDate = selected;
      });
    }
  }
}
