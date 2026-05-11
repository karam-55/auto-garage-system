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
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'إجمالي الحجوزات',
                        stats['totalBookings']?.toString() ?? '0',
                        Icons.book,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'إجمالي العملاء',
                        stats['totalCustomers']?.toString() ?? '0',
                        Icons.people,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'إجمالي السيارات',
                        stats['totalVehicles']?.toString() ?? '0',
                        Icons.directions_car,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'في الورشة',
                        stats['vehiclesInWorkshop']?.toString() ?? '0',
                        Icons.build,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Revenue Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الإيرادات (الشهر الحالي)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${revenueStats['totalRevenue']?.toString() ?? '0'} ل.س',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'عدد التسليمات: ${revenueStats['totalDeliveries'] ?? '0'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Booking Status Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'حالة الحجوزات',
                          style: TextStyle(
                            fontSize: 18,
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
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
