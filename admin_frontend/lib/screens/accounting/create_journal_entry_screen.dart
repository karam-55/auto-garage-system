import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/accounting_providers.dart';
import '../../core/models/account.dart';
import '../../core/models/journal_entry.dart';
import '../../core/services/api_service.dart';

class CreateJournalEntryScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const CreateJournalEntryScreen({super.key, required this.apiService});

  @override
  ConsumerState<CreateJournalEntryScreen> createState() => _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState extends ConsumerState<CreateJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController(text: DateTime.now().toLocal().toString().split(' ')[0]);
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<JournalLineInput> _lines = [];
  List<Account> _accounts = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _addLine(); // Add first line by default
  }

  @override
  void dispose() {
    _dateController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await ref.read(accountsProvider.future);
      setState(() {
        _accounts = accounts.where((a) => a.isActive).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الحسابات: $e')),
        );
      }
    }
  }

  void _addLine() {
    setState(() {
      _lines.add(JournalLineInput());
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines.removeAt(index);
    });
  }

  double get totalDebit => _lines.fold(0.0, (sum, line) => sum + (line.debit ?? 0.0));
  double get totalCredit => _lines.fold(0.0, (sum, line) => sum + (line.credit ?? 0.0));

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      _dateController.text = picked.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة سطر واحد على الأقل')),
      );
      return;
    }

    if ((totalDebit - totalCredit).abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('مجموع المدين ($totalDebit) لا يساوي مجموع الدائن ($totalCredit)')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final linesData = _lines.map((line) {
        return {
          'accountId': line.accountId,
          'debit': line.debit ?? 0.0,
          'credit': line.credit ?? 0.0,
          'description': line.description,
        };
      }).toList();

      final data = {
        'date': _dateController.text,
        'reference': _referenceController.text,
        'description': _descriptionController.text,
        'lines': linesData,
        'sourceType': 'manual',
      };

      await ref.read(createJournalEntryProvider(data).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ القيد بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ القيد: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء قيد يدوي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAccounts,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                          TextFormField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              labelText: 'التاريخ',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: _selectDate,
                              ),
                            ),
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى اختيار التاريخ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _referenceController,
                            decoration: const InputDecoration(labelText: 'المرجع (اختياري)'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(labelText: 'الوصف'),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال الوصف';
                              }
                              return null;
                            },
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'سطور القيد',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              ElevatedButton.icon(
                                onPressed: _addLine,
                                icon: const Icon(Icons.add),
                                label: const Text('إضافة سطر'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._lines.asMap().entries.map((entry) {
                            final index = entry.key;
                            final line = entry.value;
                            return _buildLineCard(index, line);
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('إجمالي المدين:'),
                              Text(
                                totalDebit.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('إجمالي الدائن:'),
                              Text(
                                totalCredit.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الفرق:'),
                              Text(
                                (totalDebit - totalCredit).abs() < 0.01
                                    ? '0.00'
                                    : (totalDebit - totalCredit).toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (totalDebit - totalCredit).abs() < 0.01
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveEntry,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('حفظ القيد'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLineCard(int index, JournalLineInput line) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سطر ${index + 1}'),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeLine(index),
                  tooltip: 'حذف السطر',
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: line.accountId,
              decoration: const InputDecoration(
                labelText: 'الحساب',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              items: _accounts.map((account) {
                return DropdownMenuItem<int>(
                  value: account.id,
                  child: Text('${account.code} - ${account.nameAr}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  line.accountId = value;
                  line.accountName = _accounts.firstWhere((a) => a.id == value).nameAr;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'يرجى اختيار حساب';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'مدين',
                      prefixIcon: Icon(Icons.arrow_upward, color: Colors.green),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    initialValue: line.debit?.toString(),
                    onChanged: (value) {
                      line.debit = double.tryParse(value);
                      line.credit = null; // Clear credit when debit is entered
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'دائن',
                      prefixIcon: Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    initialValue: line.credit?.toString(),
                    onChanged: (value) {
                      line.credit = double.tryParse(value);
                      line.debit = null; // Clear debit when credit is entered
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'وصف السطر (اختياري)'),
              initialValue: line.description,
              onChanged: (value) {
                line.description = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class JournalLineInput {
  int? accountId;
  String? accountName;
  double? debit;
  double? credit;
  String? description;
}
