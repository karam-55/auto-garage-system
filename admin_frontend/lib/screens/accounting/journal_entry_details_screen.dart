import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/accounting_providers.dart';
import '../../core/models/journal_entry.dart';
import '../../core/services/api_service.dart';

class JournalEntryDetailsScreen extends ConsumerStatefulWidget {
  final int entryId;
  final ApiService apiService;

  const JournalEntryDetailsScreen({super.key, required this.entryId, required this.apiService});

  @override
  ConsumerState<JournalEntryDetailsScreen> createState() => _JournalEntryDetailsScreenState();
}

class _JournalEntryDetailsScreenState extends ConsumerState<JournalEntryDetailsScreen> {
  JournalEntry? _entry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    setState(() => _isLoading = true);
    try {
      final entry = await ref.read(journalEntryDetailsProvider(entryId).future);
      setState(() {
        _entry = entry;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل القيد: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل القيد'),
        actions: [
          if (_entry != null && _entry!.sourceType == 'manual')
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () => _printEntry(),
              tooltip: 'طباعة',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entry == null
              ? const Center(child: Text('لم يتم العثور على القيد'))
              : SingleChildScrollView(
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
                                'معلومات القيد',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('التاريخ:', _entry!.date.toLocal().toString().split(' ')[0]),
                              _buildInfoRow('المرجع:', _entry!.reference),
                              _buildInfoRow('الوصف:', _entry!.description),
                              _buildInfoRow('المصدر:', _getSourceTypeLabel(_entry!.sourceType)),
                              _buildInfoRow('تاريخ الإنشاء:', _entry!.createdAt.toLocal().toString().split(' ')[0]),
                              if (_entry!.sourceId != null)
                                _buildInfoRow('رقم المصدر:', _entry!.sourceId!),
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
                                'سطور القيد',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              Table(
                                border: TableBorder.all(color: Colors.grey[300]!),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(2),
                                },
                                children: [
                                  const TableRow(
                                    decoration: BoxDecoration(color: Colors.grey),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('الحساب', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('الوصف', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('مدين', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('دائن', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  ..._entry!.lines.map((line) {
                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(line.accountName),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(line.description ?? ''),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            line.debit > 0 ? line.debit.toStringAsFixed(2) : '-',
                                            style: TextStyle(color: line.debit > 0 ? Colors.green : Colors.grey),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            line.credit > 0 ? line.credit.toStringAsFixed(2) : '-',
                                            style: TextStyle(color: line.credit > 0 ? Colors.red : Colors.grey),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                  TableRow(
                                    decoration: const BoxDecoration(color: Colors.grey),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      const Padding(padding: EdgeInsets.all(8), child: Text('')),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          _entry!.totalDebit.toStringAsFixed(2),
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          _entry!.totalCredit.toStringAsFixed(2),
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_entry!.sourceType == 'manual')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _printEntry(),
                                icon: const Icon(Icons.print),
                                label: const Text('طباعة'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                label: const Text('إغلاق'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getSourceTypeLabel(String sourceType) {
    switch (sourceType.toLowerCase()) {
      case 'manual':
        return 'يدوي';
      case 'booking':
        return 'حجز';
      case 'booking_consume':
        return 'استهلاك';
      case 'inventory_purchase':
        return 'شراء مخزون';
      default:
        return sourceType;
    }
  }

  Future<void> _printEntry() async {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة ميزة الطباعة قريباً')),
    );
  }
}
