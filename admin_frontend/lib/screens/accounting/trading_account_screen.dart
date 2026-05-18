import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/report_providers.dart';

class TradingAccountScreen extends ConsumerStatefulWidget {
  const TradingAccountScreen({super.key});

  @override
  ConsumerState<TradingAccountScreen> createState() => _TradingAccountScreenState();
}

class _TradingAccountScreenState extends ConsumerState<TradingAccountScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المتجارة'),
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
            ref.watch(tradingAccountProvider({'from': _fromDate, 'to': _toDate})).when(
              data: (data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard('إجمالي الإيرادات', data['totalRevenue'] as double, Colors.blue),
                    const SizedBox(height: 16),
                    _buildSummaryCard('إجمالي تكلفة البضاعة المباعة', data['totalCogs'] as double, Colors.red),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.green.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إجمالي الربح',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              (data['grossProfit'] as double).toStringAsFixed(2),
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
