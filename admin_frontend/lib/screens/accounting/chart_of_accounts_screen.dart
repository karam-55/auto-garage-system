import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/accounting_providers.dart';
import '../../core/models/account.dart';
import '../../core/services/api_service.dart';

class ChartOfAccountsScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const ChartOfAccountsScreen({super.key, required this.apiService});

  @override
  ConsumerState<ChartOfAccountsScreen> createState() => _ChartOfAccountsScreenState();
}

class _ChartOfAccountsScreenState extends ConsumerState<ChartOfAccountsScreen> {
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await ref.read(accountsProvider.future);
      setState(() {
        _accounts = accounts;
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

  List<Account> _buildAccountTree(List<Account> accounts) {
    final Map<int, List<Account>> childrenMap = {};
    final List<Account> rootAccounts = [];

    for (final account in accounts) {
      if (account.parentId != null) {
        childrenMap.putIfAbsent(account.parentId!, () => []).add(account);
      } else {
        rootAccounts.add(account);
      }
    }

    for (final account in accounts) {
      if (childrenMap.containsKey(account.id)) {
        account.children = childrenMap[account.id]!;
        _buildAccountTree(account.children!);
      }
    }

    return rootAccounts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل الحسابات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAccounts,
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAccountDialog(),
            tooltip: 'إضافة حساب رئيسي',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAccountTree(_accounts).isEmpty
              ? const Center(child: Text('لا توجد حسابات'))
              : ListView.builder(
                  itemCount: _buildAccountTree(_accounts).length,
                  itemBuilder: (context, index) {
                    final account = _buildAccountTree(_accounts)[index];
                    return _buildAccountTile(account);
                  },
                ),
    );
  }

  Widget _buildAccountTile(Account account, {int level = 0}) {
    return ExpansionTile(
      leading: Icon(
        account.children != null && account.children!.isNotEmpty
            ? Icons.folder
            : Icons.account_balance_wallet,
        color: _getAccountTypeColor(account.accountType),
      ),
      title: Padding(
        padding: EdgeInsets.only(left: level * 16.0),
        child: Row(
          children: [
            Text(
              account.code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: account.isActive ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                account.nameAr,
                style: TextStyle(
                  color: account.isActive ? Colors.black : Colors.grey,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getAccountTypeLabel(account.accountType),
                style: TextStyle(
                  fontSize: 12,
                  color: _getAccountTypeColor(account.accountType),
                ),
              ),
            ),
          ],
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(left: level * 16.0),
        child: Row(
          children: [
            Icon(
              account.isActive ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: account.isActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              account.isActive ? 'نشط' : 'غير نشط',
              style: TextStyle(
                fontSize: 12,
                color: account.isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAccountDialog(parentAccount: account),
            tooltip: 'إضافة حساب فرعي',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showAccountDialog(account: account),
            tooltip: 'تعديل',
          ),
          IconButton(
            icon: Icon(account.isActive ? Icons.visibility_off : Icons.visibility),
            onPressed: () => _toggleAccountStatus(account),
            tooltip: account.isActive ? 'تعطيل' : 'تفعيل',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteAccount(account),
            tooltip: 'حذف',
          ),
        ],
      ),
      children: account.children != null
          ? account.children!.map((child) => _buildAccountTile(child, level: level + 1)).toList()
          : [],
    );
  }

  Color _getAccountTypeColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'asset':
        return Colors.blue;
      case 'liability':
        return Colors.red;
      case 'equity':
        return Colors.green;
      case 'revenue':
        return Colors.purple;
      case 'expense':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getAccountTypeLabel(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'asset':
        return 'أصول';
      case 'liability':
        return 'خصوم';
      case 'equity':
        return 'حقوق الملكية';
      case 'revenue':
        return 'إيرادات';
      case 'expense':
        return 'مصروفات';
      default:
        return accountType;
    }
  }

  void _showAccountDialog({Account? account, Account? parentAccount}) {
    final codeController = TextEditingController(text: account?.code ?? '');
    final nameArController = TextEditingController(text: account?.nameAr ?? '');
    final nameEnController = TextEditingController(text: account?.nameEn ?? '');
    final accountTypeController = TextEditingController(text: account?.accountType ?? '');
    final isActive = account?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account == null ? 'إضافة حساب جديد' : 'تعديل الحساب'),
        content: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (parentAccount != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'حساب فرعي تحت: ${parentAccount.code} - ${parentAccount.nameAr}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'الكود'),
                  keyboardType: TextInputType.text,
                ),
                TextFormField(
                  controller: nameArController,
                  decoration: const InputDecoration(labelText: 'الاسم بالعربية'),
                ),
                TextFormField(
                  controller: nameEnController,
                  decoration: const InputDecoration(labelText: 'الاسم بالإنجليزية'),
                ),
                DropdownButtonFormField<String>(
                  value: accountTypeController.text.isEmpty ? null : accountTypeController.text,
                  decoration: const InputDecoration(labelText: 'نوع الحساب'),
                  items: const [
                    DropdownMenuItem(value: 'asset', child: Text('أصول')),
                    DropdownMenuItem(value: 'liability', child: Text('خصوم')),
                    DropdownMenuItem(value: 'equity', child: Text('حقوق الملكية')),
                    DropdownMenuItem(value: 'revenue', child: Text('إيرادات')),
                    DropdownMenuItem(value: 'expense', child: Text('مصروفات')),
                  ],
                  onChanged: (value) {
                    accountTypeController.text = value ?? '';
                  },
                ),
                SwitchListTile(
                  title: const Text('نشط'),
                  value: isActive,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.isEmpty || nameArController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
                );
                return;
              }

              try {
                final data = {
                  'code': codeController.text,
                  'nameAr': nameArController.text,
                  'nameEn': nameEnController.text,
                  'accountType': accountTypeController.text,
                  'parentId': parentAccount?.id,
                  'isActive': isActive,
                };

                if (account == null) {
                  await ref.read(createAccountProvider(data).future);
                } else {
                  data['id'] = account.id;
                  await ref.read(updateAccountProvider(data).future);
                }

                Navigator.pop(context);
                await _loadAccounts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الحساب بنجاح')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ في حفظ الحساب: $e')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAccountStatus(Account account) async {
    try {
      final data = account.copyWith(isActive: !account.isActive).toJson();
      await ref.read(updateAccountProvider(data).future);
      await _loadAccounts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم ${account.isActive ? 'تعطيل' : 'تفعيل'} الحساب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تغيير حالة الحساب: $e')),
      );
    }
  }

  Future<void> _deleteAccount(Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الحساب "${account.nameAr}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(deleteAccountProvider(account.id).future);
        await _loadAccounts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الحساب بنجاح')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حذف الحساب: $e')),
        );
      }
    }
  }
}
