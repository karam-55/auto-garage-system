import 'package:flutter/material.dart';
import '../core/widgets/loading_screen.dart';
import '../core/services/api_service.dart';
import '../core/services/websocket_service.dart';
import '../core/constants/api_constants.dart';

class OverviewScreen extends StatefulWidget {
  final ApiService apiService;

  const OverviewScreen({super.key, required this.apiService});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  late AnimationController _staggerController;
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _loadStats();
    
    // Connect to WebSocket
    _webSocketService.connect();
    
    // Listen for booking updates
    _webSocketService.addListener(_onBookingUpdate);
  }

  void _onBookingUpdate() {
    final update = _webSocketService.lastBookingUpdate;
    if (update != null) {
      // Reload stats when a booking is updated
      _loadStats();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _webSocketService.removeListener(_onBookingUpdate);
    _webSocketService.disconnect();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل الإحصائيات: $e')));
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
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('فشل تحميل الإحصائيات', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('يرجى المحاولة مرة أخرى', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStatsCards(),
          const SizedBox(height: 20),
          _buildBookingsByStatus(),
          const SizedBox(height: 20),
          _buildRevenueCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نظرة عامة على النظام', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('مرحباً بك في لوحة التحكم', style: TextStyle(color: Colors.grey.shade600)),
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
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _StatCard(
              title: 'إجمالي الحجوزات',
              value: '${_stats!['totalBookings'] ?? 0}',
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF6366F1),
            ),
            _StatCard(
              title: 'إجمالي العملاء',
              value: '${_stats!['totalCustomers'] ?? 0}',
              icon: Icons.people_rounded,
              color: const Color(0xFF10B981),
            ),
            _StatCard(
              title: 'إجمالي المركبات',
              value: '${_stats!['totalVehicles'] ?? 0}',
              icon: Icons.directions_car_rounded,
              color: const Color(0xFFF59E0B),
            ),
            _StatCard(
              title: 'المركبات في الورشة',
              value: '${_stats!['vehiclesInWorkshop'] ?? 0}',
              icon: Icons.build_rounded,
              color: const Color(0xFFEF4444),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookingsByStatus() {
    final bookingsByStatus = _stats!['bookingsByStatus'] as Map<String, dynamic>?;
    if (bookingsByStatus == null) return const SizedBox();

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
          Text('الحجوزات حسب الحالة', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
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
      spacing: 8,
      runSpacing: 8,
      children: statusData.map((data) {
        return _StatusChip(
          label: data['label'],
          value: data['value'],
          color: data['color'],
        );
      }).toList(),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.08),
            const Color(0xFF6366F1).withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up_rounded, size: 28, color: Color(0xFF6366F1)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الإيرادات الشهرية', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  '${(_stats!['monthlyRevenue'] ?? 0).toStringAsFixed(0)} ل.س',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_upward, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text('+15.3%', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatusChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 12,
            child: Text('$value', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
