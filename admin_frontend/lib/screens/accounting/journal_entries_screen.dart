import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/accounting_providers.dart';
import '../../core/models/journal_entry.dart';
import '../../core/services/api_service.dart';
import 'create_journal_entry_screen.dart';
import 'journal_entry_details_screen.dart';

class JournalEntriesScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const JournalEntriesScreen({super.key, required this.apiService});

  @override
  ConsumerState<JournalEntriesScreen> createState() => _JournalEntriesScreenState();
}

class _JournalEntriesScreenState extends ConsumerState<JournalEntriesScreen> {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  DateTime? _fromDate;
  DateTime? _toDate;
  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final filters = <String, dynamic>{
        'page': _page,
        'limit': _limit,
      };
      if (_fromDate != null) {
        filters['from'] = _fromDate!.toIso8601String();
      }
      if (_toDate != null) {
        filters['to'] = _toDate!.toIso8601String();
      }

      final entries = await ref.read(journalEntriesProvider(filters).future);
      setState(() {
        if (_page == 1) {
          _entries = entries;
        } else {
          _entries.addAll(entries);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل القيود: $e')),
        );
      }
    }
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
        _page = 1;
      });
      await _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القيود اليومية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'تصفية حسب التاريخ',
          ),
          if (_fromDate != null || _toDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _fromDate = null;
                  _toDate = null;
                  _page = 1;
                });
                _loadEntries();
              },
              tooltip: 'مسح التصفية',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _page = 1;
              _loadEntries();
            },
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateJournalEntryScreen(apiService: widget.apiService),
                ),
              );
              _page = 1;
              _loadEntries();
            },
            tooltip: 'إضافة قيد يدوي',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('لا توجد قيود'),
                      if (_fromDate != null || _toDate != null) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _fromDate = null;
                              _toDate = null;
                              _page = 1;
                            });
                            _loadEntries();
                          },
                          child: const Text('مسح التصفية'),
                        ),
                      ],
                    ],
                  ),
                )
              : Column(
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
                              _page = 1;
                            });
                            _loadEntries();
                          },
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _entries.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _entries.length) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : TextButton(
                                        onPressed: () {
                                          _page++;
                                          _loadEntries();
                                        },
                                        child: const Text('تحميل المزيد'),
                                      ),
                              ),
                            );
                          }

                          final entry = _entries[index];
                          return _buildEntryCard(entry);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            entry.date.day.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          entry.reference,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  entry.date.toLocal().toString().split(' ')[0],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.description, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${entry.lines.length} سطر',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${entry.totalDebit.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSourceTypeColor(entry.sourceType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getSourceTypeLabel(entry.sourceType),
                style: TextStyle(
                  fontSize: 12,
                  color: _getSourceTypeColor(entry.sourceType),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JournalEntryDetailsScreen(
                entryId: entry.id,
                apiService: widget.apiService,
              ),
            ),
          );
          _page = 1;
          _loadEntries();
        },
      ),
    );
  }

  Color _getSourceTypeColor(String sourceType) {
    switch (sourceType.toLowerCase()) {
      case 'manual':
        return Colors.blue;
      case 'booking':
        return Colors.purple;
      case 'booking_consume':
        return Colors.orange;
      case 'inventory_purchase':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
}
