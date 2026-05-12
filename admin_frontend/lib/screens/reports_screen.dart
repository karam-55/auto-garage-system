import 'package:flutter/material.dart';
import '../core/widgets/loading_screen.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class ReportsScreen extends StatefulWidget {
  final ApiService apiService;

  const ReportsScreen({super.key, required this.apiService});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? _revenueData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.dashboardRevenue);
      setState(() {
        _revenueData = response is Map<String, dynamic> ? response : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل التقارير: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildRevenueSummary(),
            const SizedBox(height: 32),
            _buildMonthlyRevenueChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'التقارير والإحصائيات',
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildRevenueSummary() {
    if (_revenueData == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                'ملخص الإيرادات',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildRevenueRow('إجمالي الإيرادات', '${(_revenueData!['totalRevenue'] ?? 0).toStringAsFixed(0)} ل.س'),
          const SizedBox(height: 12),
          _buildRevenueRow('إيرادات هذا الشهر', '${(_revenueData!['monthlyRevenue'] ?? 0).toStringAsFixed(0)} ل.س'),
          const SizedBox(height: 12),
          _buildRevenueRow('متوسط الإيرادات اليومية', '${(_revenueData!['averageDailyRevenue'] ?? 0).toStringAsFixed(0)} ل.س'),
        ],
      ),
    );
  }

  Widget _buildRevenueRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildMonthlyRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإيرادات الشهرية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),
          _buildChartPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'مخطط الإيرادات',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إضافة المخطط في التحديث القادم',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
