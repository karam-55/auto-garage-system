import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/report_providers.dart';

class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key});

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير التدفقات النقدية'),
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
            ref.watch(cashFlowProvider({'from': _fromDate, 'to': _toDate})).when(
              data: (data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard('صافي الربح', data['netProfit'] as double, Colors.blue),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التعديلات',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _buildAdjustmentRow('التغير في الذمم المدينة', data['adjustments']['changeInReceivables'] as double),
                            _buildAdjustmentRow('التغير في المخزون', data['adjustments']['changeInInventory'] as double),
                            _buildAdjustmentRow('التغير في الموردين', data['adjustments']['changeInPayables'] as double),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard('التدفق النقدي من العمليات التشغيلية', data['cashFlowFromOperations'] as double, Colors.green),
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

  Widget _buildSummaryCard(String title, double value, Color color) {
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
              value.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: value >= 0 ? Colors.green : Colors.red,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              color: value >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
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
