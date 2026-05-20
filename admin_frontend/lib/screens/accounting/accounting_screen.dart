import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/accounting_providers.dart';
import 'trial_balance_screen.dart';
import 'profit_loss_screen.dart';
import 'balance_sheet_screen.dart';
import 'general_ledger_screen.dart';
import 'cash_flow_screen.dart';

class AccountingScreen extends ConsumerWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحاسبة'),
        bottom: TabBar(
          tabs: const [
            Tab(text: 'الحسابات'),
            Tab(text: 'قيود اليومية'),
            Tab(text: 'التقارير'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          AccountsTab(),
          JournalEntriesTab(),
          ReportsTab(),
        ],
      ),
    );
  }
}

class AccountsTab extends ConsumerWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('شاشة الحسابات قيد التطوير'),
    );
  }
}

class JournalEntriesTab extends ConsumerWidget {
  const JournalEntriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('شاشة قيود اليومية قيد التطوير'),
    );
  }
}

class ReportsTab extends ConsumerWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          'ميزان المراجعة',
          'Trial Balance',
          Icons.balance,
          Colors.blue,
          () => _navigateToReport(context, ref, 'trial_balance'),
        ),
        _buildReportCard(
          'قائمة الدخل',
          'Profit & Loss',
          Icons.trending_up,
          Colors.green,
          () => _navigateToReport(context, ref, 'profit_loss'),
        ),
        _buildReportCard(
          'الميزانية العمومية',
          'Balance Sheet',
          Icons.account_balance,
          Colors.purple,
          () => _navigateToReport(context, ref, 'balance_sheet'),
        ),
        _buildReportCard(
          'دفتر الأستاذ العام',
          'General Ledger',
          Icons.book,
          Colors.orange,
          () => _navigateToReport(context, ref, 'general_ledger'),
        ),
        _buildReportCard(
          'بيان التدفق النقدي',
          'Cash Flow Statement',
          Icons.payments,
          Colors.red,
          () => _navigateToReport(context, ref, 'cash_flow'),
        ),
      ],
    );
  }

  Widget _buildReportCard(
    String titleAr,
    String titleEn,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(titleAr),
        subtitle: Text(titleEn),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _navigateToReport(BuildContext context, WidgetRef ref, String reportType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountingReportScreen(reportType: reportType),
      ),
    );
  }
}

class AccountingReportScreen extends StatefulWidget {
  final String reportType;

  const AccountingReportScreen({super.key, required this.reportType});

  @override
  State<AccountingReportScreen> createState() => _AccountingReportScreenState();
}

class _AccountingReportScreenState extends State<AccountingReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getReportTitle()),
      ),
      body: Center(
        child: Text('تقرير ${_getReportTitle()} قيد التطوير'),
      ),
    );
  }

  String _getReportTitle() {
    switch (widget.reportType) {
      case 'trial_balance':
        return 'ميزان المراجعة';
      case 'profit_loss':
        return 'قائمة الدخل';
      case 'balance_sheet':
        return 'الميزانية العمومية';
      case 'general_ledger':
        return 'دفتر الأستاذ العام';
      case 'cash_flow':
        return 'بيان التدفق النقدي';
      default:
        return 'تقرير';
    }
  }
}
