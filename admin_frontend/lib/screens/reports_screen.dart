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

  // Format number with thousands separator
  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    double num = 0;
    if (price is double) {
      num = price;
    } else if (price is int) {
      num = price.toDouble();
    } else if (price is String) {
      num = double.tryParse(price) ?? 0;
    }
    return num.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  void initState() {
    super.initState();
    print('ReportsScreen: initState called');
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    print('ReportsScreen: _loadRevenueData called');
    setState(() => _isLoading = true);
    try {
      print('ReportsScreen: Calling API.get with endpoint: ${ApiConstants.dashboardRevenue}');
      final response = await widget.apiService.get(ApiConstants.dashboardRevenue);
      print('ReportsScreen: API response received: $response');
      setState(() {
        _revenueData = response is Map<String, dynamic> ? response : null;
        _isLoading = false;
      });
      if (_revenueData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا توجد بيانات إيرادات متاحة')),
          );
        }
      }
    } catch (e) {
      print('ReportsScreen: Error loading revenue data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل التقارير: $e')),
        );
      }
    }
  }

  Future<void> _exportToPDF() async {
    try {
      final response = await widget.apiService.get('${ApiConstants.baseUrl}/api/reports/bookings/pdf');
      // Handle PDF download
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تصدير التقرير بنجاح')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تصدير PDF: $e')),
        );
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final response = await widget.apiService.get('${ApiConstants.baseUrl}/api/reports/bookings/excel');
      // Handle Excel download
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تصدير التقرير بنجاح')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تصدير Excel: $e')),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التقارير والإحصائيات',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _exportToPDF,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('تصدير PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _exportToExcel,
                      icon: const Icon(Icons.table_chart),
                      label: const Text('تصدير Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
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
            value: '${_formatPrice(_revenueData!['totalRevenue'] ?? 0)} ل.س',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF6366F1),
          ),
          _RevenueItem(
            label: 'الإيراد الشهري',
            value: '${_formatPrice(_revenueData!['monthlyRevenue'] ?? 0)} ل.س',
            icon: Icons.calendar_month_rounded,
            color: const Color(0xFF10B981),
          ),
          _RevenueItem(
            label: 'متوسط الإيراد اليومي',
            value: '${_formatPrice(_revenueData!['averageDailyRevenue'] ?? 0)} ل.س',
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
                  color: item.color.withValues(alpha: 0.1),
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
