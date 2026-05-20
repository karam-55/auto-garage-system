import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/report_providers.dart';

class BalanceSheetScreen extends ConsumerWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BalanceSheetScreenContent();
  }
}

class _BalanceSheetScreenContent extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BalanceSheetScreenContent> createState() => _BalanceSheetScreenContentState();
}

class _BalanceSheetScreenContentState extends ConsumerState<_BalanceSheetScreenContent> {
  DateTime? _asOfDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الميزانية العمومية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'اختر التاريخ',
          ),
          if (_asOfDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _asOfDate = null;
                });
              },
              tooltip: 'مسح التصفية',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_asOfDate != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Chip(
                label: Text('حتى ${_asOfDate?.toLocal().toString().split(' ')[0]}'),
                onDeleted: () {
                  setState(() {
                    _asOfDate = null;
                  });
                },
              ),
            ),
          Expanded(
            child: _buildBalanceSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSheet() {
    final params = <String, dynamic>{};
    if (_asOfDate != null) {
      params['asOfDate'] = _asOfDate;
    }

    return ref.watch(balanceSheetProvider(params)).when(
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

        final assets = data['assets'] as List<dynamic>? ?? [];
        final liabilities = data['liabilities'] as List<dynamic>? ?? [];
        final totalAssets = data['totalAssets'] as num? ?? 0;
        final totalLiabilities = data['totalLiabilities'] as num? ?? 0;
        final equity = data['equity'] as num? ?? 0;

        if (assets.isEmpty && liabilities.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا توجد بيانات للأصول والخصوم'),
                SizedBox(height: 8),
                Text('أضف قيود يومية أولاً لعرض الميزانية العمومية'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assets Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الأصول',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (assets.isEmpty)
                        const Text('لا توجد أصول')
                      else
                        ...assets.map((item) {
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
                                  (item['balance'] as num).toStringAsFixed(2),
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
                            'إجمالي الأصول',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            totalAssets.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Liabilities Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الخصوم',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (liabilities.isEmpty)
                        const Text('لا توجد خصوم')
                      else
                        ...liabilities.map((item) {
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
                                  (item['balance'] as num).toStringAsFixed(2),
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
                            'إجمالي الخصوم',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            totalLiabilities.toStringAsFixed(2),
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
              // Equity Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حقوق الملكية',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي حقوق الملكية',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            equity.toStringAsFixed(2),
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
              // Balance Check
              Card(
                color: (totalAssets - (totalLiabilities + equity)).abs() < 0.01
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الأصول = الخصوم + حقوق الملكية',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            (totalAssets - (totalLiabilities + equity)).abs() < 0.01
                                ? '✓ متوازن'
                                : '✗ غير متوازن',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (totalAssets - (totalLiabilities + equity)).abs() < 0.01
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الأصول:'),
                          Text(totalAssets.toStringAsFixed(2)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الخصوم + حقوق الملكية:'),
                          Text((totalLiabilities + equity).toStringAsFixed(2)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الفرق:'),
                          Text(
                            (totalAssets - (totalLiabilities + equity)).toStringAsFixed(2),
                          ),
                        ],
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _asOfDate = picked;
      });
    }
  }
}
