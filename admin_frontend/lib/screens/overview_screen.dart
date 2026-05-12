import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/widgets/animated_card.dart';
import '../core/widgets/loading_screen.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class OverviewScreen extends StatefulWidget {
  final ApiService apiService;

  const OverviewScreen({super.key, required this.apiService});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadStats();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.dashboardStats);
      setState(() {
        _stats = response is Map<String, dynamic> ? response : null;
        _isLoading = false;
      });
      if (_stats != null) {
        _staggerController.forward();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الإحصائيات: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionLoading(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'فشل تحميل الإحصائيات',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى المحاولة مرة أخرى',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildStatsCards(),
          const SizedBox(height: 32),
          _buildBookingsByStatus(),
          const SizedBox(height: 32),
          _buildRevenueCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نظرة عامة على النظام',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'مرحباً بك في لوحة التحكم',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 600
                    ? 2
                    : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: 'إجمالي الحجوزات',
              value: '${_stats!['totalBookings'] ?? 0}',
              icon: Icons.calendar_today_rounded,
              color: Theme.of(context).colorScheme.primary,
              percentageChange: 12.5,
              delay: 0,
            ),
            _buildStatCard(
              title: 'إجمالي العملاء',
              value: '${_stats!['totalCustomers'] ?? 0}',
              icon: Icons.people_rounded,
              color: const Color(0xFF10B981),
              percentageChange: 8.3,
              delay: 150,
            ),
            _buildStatCard(
              title: 'إجمالي المركبات',
              value: '${_stats!['totalVehicles'] ?? 0}',
              icon: Icons.directions_car_rounded,
              color: const Color(0xFFF59E0B),
              percentageChange: -2.1,
              delay: 300,
            ),
            _buildStatCard(
              title: 'المركبات في الورشة',
              value: '${_stats!['vehiclesInWorkshop'] ?? 0}',
              icon: Icons.build_rounded,
              color: const Color(0xFFEF4444),
              percentageChange: 5.7,
              delay: 450,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    double? percentageChange,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Opacity(
            opacity: animationValue,
            child: AnimatedDashboardCard(
              title: title,
              value: value,
              icon: icon,
              color: color,
              percentageChange: percentageChange,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingsByStatus() {
    final bookingsByStatus = _stats!['bookingsByStatus'] as Map<String, dynamic>?;
    if (bookingsByStatus == null) return const SizedBox();

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
            'الحجوزات حسب الحالة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          _buildStatusChips(bookingsByStatus),
        ],
      ),
    );
  }

  Widget _buildStatusChips(Map<String, dynamic> bookingsByStatus) {
    final statusData = [
      {'label': 'معلق', 'value': bookingsByStatus['pending'] ?? 0, 'color': Colors.grey},
      {'label': 'قيد التنفيذ', 'value': bookingsByStatus['inProgress'] ?? 0, 'color': Colors.blue},
      {'label': 'في انتظار قطع الغيار', 'value': bookingsByStatus['waitingParts'] ?? 0, 'color': Colors.orange},
      {'label': 'جاهز', 'value': bookingsByStatus['ready'] ?? 0, 'color': Colors.green},
      {'label': 'تم التسليم', 'value': bookingsByStatus['delivered'] ?? 0, 'color': Colors.teal},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: statusData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100)),
          builder: (context, animationValue, child) {
            return Transform.scale(
              scale: animationValue,
              child: Opacity(
                opacity: animationValue,
                child: _buildStatusChip(
                  data['label'],
                  data['value'],
                  data['color'],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildStatusChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 16,
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
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
      child: Row(
        children: [
          Icon(
            Icons.trending_up_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإيرادات الشهرية',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_stats!['monthlyRevenue'] ?? 0).toStringAsFixed(0)} ل.س',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_upward,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '+15.3%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
