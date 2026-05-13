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
          SnackBar(content: Text('خطأ في تحميل التقارير: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقارير والإحصائيات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            _buildRevenueCards(),
            const SizedBox(height: 20),
            _buildChartPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCards() {
    if (_revenueData == null) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 3 : 1;
        final items = [
          _RevenueItem(
            label: 'إجمالي الإيرادات',
            value: '${(_revenueData!['totalRevenue'] ?? 0).toStringAsFixed(0)} ل.س',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF6366F1),
          ),
          _RevenueItem(
            label: 'إيرادات هذا الشهر',
            value: '${(_revenueData!['monthlyRevenue'] ?? 0).toStringAsFixed(0)} ل.س',
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF10B981),
          ),
          _RevenueItem(
            label: 'متوسط يومي',
            value: '${(_revenueData!['averageDailyRevenue'] ?? 0).toStringAsFixed(0)} ل.س',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFFF59E0B),
          ),
        ];

        if (crossAxisCount == 1) {
          return Column(
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RevenueCard(item: item),
            )).toList(),
          );
        }

        return Row(
          children: items.map((item) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _RevenueCard(item: item),
          ))).toList(),
        );
      },
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإيرادات الشهرية',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'مخطط الإيرادات',
                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سيتم إضافة المخطط في التحديث القادم',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _RevenueItem({required this.label, required this.value, required this.icon, required this.color});
}

class _RevenueCard extends StatelessWidget {
  final _RevenueItem item;
  const _RevenueCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: item.color),
          ),
        ],
      ),
    );
  }
}
