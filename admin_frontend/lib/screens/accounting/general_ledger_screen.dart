import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/report_providers.dart';
import '../../core/providers/accounting_providers.dart';

class GeneralLedgerScreen extends ConsumerWidget {
  const GeneralLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GeneralLedgerScreenContent();
  }
}

class _GeneralLedgerScreenContent extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GeneralLedgerScreenContent> createState() => _GeneralLedgerScreenContentState();
}

class _GeneralLedgerScreenContentState extends ConsumerState<_GeneralLedgerScreenContent> {
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر الأستاذ العام'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: 'اختر نطاق التاريخ',
          ),
          if (_fromDate != null || _toDate != null || _selectedAccountId != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _fromDate = null;
                  _toDate = null;
                  _selectedAccountId = null;
                });
              },
              tooltip: 'مسح التصفية',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_fromDate != null || _toDate != null || _selectedAccountId != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_fromDate != null || _toDate != null)
                    Chip(
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
                  if (_selectedAccountId != null)
                    Chip(
                      label: const Text('حساب محدد'),
                      onDeleted: () {
                        setState(() {
                          _selectedAccountId = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: _buildGeneralLedger(),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralLedger() {
    final params = <String, String?>{
      'from': _fromDate?.toIso8601String(),
      'to': _toDate?.toIso8601String(),
      'accountId': _selectedAccountId?.toString(),
    };

    return ref.watch(generalLedgerProvider(params)).when(
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

        final entries = data['entries'] as List<dynamic>? ?? [];
        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا توجد قيود يومية في النظام'),
                SizedBox(height: 8),
                Text('أضف قيود يومية أولاً لعرض دفتر الأستاذ العام'),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('تصفية حسب الحساب:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ref.watch(accountsProvider).when(
                      data: (accounts) {
                        return DropdownButtonFormField<int>(
                          value: _selectedAccountId,
                          decoration: const InputDecoration(
                            hintText: 'اختر حساب',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: accounts.map((account) {
                            return DropdownMenuItem<int>(
                              value: account.id,
                              child: Text('${account.code} - ${account.nameAr}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccountId = value;
                            });
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => const Text('خطأ في تحميل الحسابات'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('التاريخ')),
                    DataColumn(label: Text('المرجع')),
                    DataColumn(label: Text('الوصف')),
                    DataColumn(label: Text('الحساب')),
                    DataColumn(label: Text('مدين'), numeric: true),
                    DataColumn(label: Text('دائن'), numeric: true),
                  ],
                  rows: entries.map<DataRow>((entry) {
                    final account = entry['account'] as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text((entry['date'] as String).split('T')[0])),
                      DataCell(Text(entry['reference'] as String)),
                      DataCell(Text(entry['description'] as String)),
                      DataCell(Text('${account['code']} - ${account['nameAr']}')),
                      DataCell(Text(
                        (entry['debit'] as num) > 0
                            ? (entry['debit'] as num).toStringAsFixed(2)
                            : '-',
                      )),
                      DataCell(Text(
                        (entry['credit'] as num) > 0
                            ? (entry['credit'] as num).toStringAsFixed(2)
                            : '-',
                      )),
                    ]);
                  }).toList(),
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
