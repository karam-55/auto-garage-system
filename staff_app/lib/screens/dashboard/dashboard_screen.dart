import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/booking_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().fetchDashboardStats();
      context.read<DashboardProvider>().fetchRevenueStats(period: 'month');
      context.read<BookingProvider>().fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardProvider>().fetchDashboardStats();
              context.read<DashboardProvider>().fetchRevenueStats(period: 'month');
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = dashboardProvider.stats;
          final revenueStats = dashboardProvider.revenueStats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      'إجمالي الحجوزات',
                      stats['totalBookings']?.toString() ?? '0',
                      Icons.book,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      'العملاء',
                      stats['totalCustomers']?.toString() ?? '0',
                      Icons.people,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'السيارات',
                      stats['totalVehicles']?.toString() ?? '0',
                      Icons.directions_car,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      'الخدمات',
                      stats['totalServices']?.toString() ?? '0',
                      Icons.build,
                      Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Revenue Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإيرادات',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${revenueStats['totalRevenue']?.toString() ?? '0'} ل.س',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        if (revenueStats['revenueChange'] != null)
                          Row(
                            children: [
                              Icon(
                                revenueStats['revenueChange'] >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: revenueStats['revenueChange'] >= 0
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${revenueStats['revenueChange'] >= 0 ? '+' : ''}${revenueStats['revenueChange']}%',
                                style: TextStyle(
                                  color: revenueStats['revenueChange'] >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Booking Status Chart
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالة الحجوزات',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _buildBookingStatusChart(stats['bookingsByStatus'] ?? {}),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStatusChart(Map<String, dynamic> statusData) {
    final data = [
      PieChartSectionData(
        value: (statusData['pending'] as int?)?.toDouble() ?? 0,
        title: 'قيد الانتظار',
        color: Colors.grey,
        radius: 50,
      ),
      PieChartSectionData(
        value: (statusData['inProgress'] as int?)?.toDouble() ?? 0,
        title: 'قيد العمل',
        color: Colors.blue,
        radius: 50,
      ),
      PieChartSectionData(
        value: (statusData['waitingParts'] as int?)?.toDouble() ?? 0,
        title: 'بانتظار القطع',
        color: Colors.orange,
        radius: 50,
      ),
      PieChartSectionData(
        value: (statusData['ready'] as int?)?.toDouble() ?? 0,
        title: 'جاهزة',
        color: Colors.green,
        radius: 50,
      ),
      PieChartSectionData(
        value: (statusData['delivered'] as int?)?.toDouble() ?? 0,
        title: 'تم التسليم',
        color: Colors.purple,
        radius: 50,
      ),
    ];

    return PieChart(
      PieChartData(
        sections: data,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}
