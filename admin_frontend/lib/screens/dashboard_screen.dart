import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة القيادة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(salesStatsProvider);
              ref.invalidate(purchaseStatsProvider);
              ref.invalidate(inventoryStatsProvider);
              ref.invalidate(manufacturingStatsProvider);
              ref.invalidate(hrStatsProvider);
              ref.invalidate(fixedAssetsStatsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(salesStatsProvider);
          ref.invalidate(purchaseStatsProvider);
          ref.invalidate(inventoryStatsProvider);
          ref.invalidate(manufacturingStatsProvider);
          ref.invalidate(hrStatsProvider);
          ref.invalidate(fixedAssetsStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مؤشرات الأداء الرئيسية',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildKPIs(context),
              const SizedBox(height: 24),
              _buildChartsSection(context),
              const SizedBox(height: 24),
              _buildTablesSection(context),
              const SizedBox(height: 24),
              _buildAlertsSection(context),
              const SizedBox(height: 24),
              const Text(
                'الإحصائيات التفصيلية',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildERPSections(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIs(BuildContext context) {
    final salesStats = ref.watch(salesStatsProvider);
    final purchaseStats = ref.watch(purchaseStatsProvider);
    final inventoryStats = ref.watch(inventoryStatsProvider);

    return Row(
      children: [
        Expanded(
          child: _KPICard(
            title: 'إجمالي المبيعات',
            value: salesStats.when(
              data: (data) => '${(data['totalSales'] as num).toStringAsFixed(0)} ل.س',
              loading: () => '...',
              error: (_, __) => 'خطأ',
            ),
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KPICard(
            title: 'إجمالي المشتريات',
            value: purchaseStats.when(
              data: (data) => '${(data['totalPurchases'] as num).toStringAsFixed(0)} ل.س',
              loading: () => '...',
              error: (_, __) => 'خطأ',
            ),
            icon: Icons.shopping_cart,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KPICard(
            title: 'صافي الربح',
            value: salesStats.when(
              data: (salesData) => purchaseStats.when(
                data: (purchaseData) {
                  final profit = (salesData['totalSales'] as num) - (purchaseData['totalPurchases'] as num);
                  return '${profit.toStringAsFixed(0)} ل.س';
                },
                loading: () => '...',
                error: (_, __) => 'خطأ',
              ),
              loading: () => '...',
              error: (_, __) => 'خطأ',
            ),
            icon: Icons.account_balance_wallet,
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KPICard(
            title: 'قيمة المخزون',
            value: inventoryStats.when(
              data: (data) => '${(data['totalValue'] as num).toStringAsFixed(0)} ل.س',
              loading: () => '...',
              error: (_, __) => 'خطأ',
            ),
            icon: Icons.inventory,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الرسوم البيانية',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المبيعات والمشتريات الشهرية',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildLineChart(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'توزيع المصروفات',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildPieChart(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 12000),
              FlSpot(1, 15000),
              FlSpot(2, 18000),
              FlSpot(3, 14000),
              FlSpot(4, 20000),
              FlSpot(5, 22000),
            ],
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 8000),
              FlSpot(1, 10000),
              FlSpot(2, 12000),
              FlSpot(3, 9000),
              FlSpot(4, 13000),
              FlSpot(5, 15000),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        minY: 0,
        maxY: 25000,
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: 35,
            color: Colors.blue,
            title: 'رواتب',
            radius: 50,
          ),
          PieChartSectionData(
            value: 25,
            color: Colors.green,
            title: 'إيجار',
            radius: 50,
          ),
          PieChartSectionData(
            value: 20,
            color: Colors.orange,
            title: 'قطع غيار',
            radius: 50,
          ),
          PieChartSectionData(
            value: 15,
            color: Colors.purple,
            title: 'كهرباء',
            radius: 50,
          ),
          PieChartSectionData(
            value: 5,
            color: Colors.red,
            title: 'أخرى',
            radius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildTablesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الجداول المختصرة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRecentPurchaseOrdersTable(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTopCustomersTable(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentPurchaseOrdersTable() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'آخر 5 أوامر شراء',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDataTable(
              headers: ['رقم الأمر', 'المورد', 'التاريخ', 'الحالة'],
              rows: const [
                ['PO-001', 'شركة الأمل', '2024-01-15', 'مكتمل'],
                ['PO-002', 'شركة النور', '2024-01-14', 'قيد التنفيذ'],
                ['PO-003', 'شركة التقدم', '2024-01-13', 'مكتمل'],
                ['PO-004', 'شركة المستقبل', '2024-01-12', 'معلق'],
                ['PO-005', 'شركة الرؤية', '2024-01-11', 'مكتمل'],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomersTable() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أعلى 5 عملاء',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDataTable(
              headers: ['اسم العميل', 'إجمالي المشتريات'],
              rows: const [
                ['أحمد محمد', '500,000 ل.س'],
                ['محمد علي', '450,000 ل.س'],
                ['خالد سعيد', '400,000 ل.س'],
                ['عمر حسن', '350,000 ل.س'],
                ['يوسف إبراهيم', '300,000 ل.س'],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable({required List<String> headers, required List<List<String>> rows}) {
    return Column(
      children: [
        // Header row
        Row(
          children: headers.map((header) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                header,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          )).toList(),
        ),
        const Divider(),
        // Data rows
        ...rows.map((row) => Column(
          children: [
            Row(
              children: row.map((cell) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    cell,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )).toList(),
            ),
            const Divider(height: 1),
          ],
        )),
      ],
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    final inventoryStats = ref.watch(inventoryStatsProvider);

    return Card(
      elevation: 4,
      color: Colors.orange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'تنبيهات سريعة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final stats = ref.watch(inventoryStatsProvider);
                return stats.when(
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((data['lowStockItems'] as int) > 0)
                        _AlertItem(
                          icon: Icons.inventory_2,
                          message: '${data['lowStockItems']} صنف منخفض المخزون',
                          color: Colors.orange,
                        ),
                      _AlertItem(
                        icon: Icons.receipt_long,
                        message: '3 فواتير شراء غير مدفوعة',
                        color: Colors.red,
                      ),
                      _AlertItem(
                        icon: Icons.build,
                        message: '2 عقود صيانة تنتهي قريباً',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('خطأ: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildERPSections(BuildContext context) {
    return ExpansionPanelList(
      expandedHeaderPadding: const EdgeInsets.all(8),
      elevation: 2,
      children: [
        _buildSalesPanel(context),
        _buildPurchasePanel(context),
        _buildInventoryPanel(context),
        _buildManufacturingPanel(context),
        _buildHRPanel(context),
        _buildFixedAssetsPanel(context),
      ],
    );
  }

  ExpansionPanel _buildSalesPanel(BuildContext context) {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) => ListTile(
        leading: const Icon(Icons.point_of_sale, color: Colors.green),
        title: const Text('المبيعات'),
        trailing: Text(isExpanded ? '▲' : '▼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer(
          builder: (context, ref, child) {
            final stats = ref.watch(salesStatsProvider);
            return stats.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow('إجمالي المبيعات', '${(data['totalSales'] as num).toStringAsFixed(2)} ل.س'),
                  _StatRow('عدد الفواتير', '${data['totalInvoices']}'),
                  _StatRow('متوسط قيمة الفاتورة', '${(data['averageInvoiceValue'] as num).toStringAsFixed(2)} ل.س'),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('خطأ: $error'),
            );
          },
        ),
      ),
      isExpanded: true,
    );
  }

  ExpansionPanel _buildPurchasePanel(BuildContext context) {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) => ListTile(
        leading: const Icon(Icons.shopping_cart, color: Colors.blue),
        title: const Text('المشتريات'),
        trailing: Text(isExpanded ? '▲' : '▼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer(
          builder: (context, ref, child) {
            final stats = ref.watch(purchaseStatsProvider);
            return stats.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow('إجمالي المشتريات', '${(data['totalPurchases'] as num).toStringAsFixed(2)} ل.س'),
                  _StatRow('عدد أوامر الشراء', '${data['totalOrders']}'),
                  _StatRow('متوسط قيمة الأمر', '${(data['averageOrderValue'] as num).toStringAsFixed(2)} ل.س'),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('خطأ: $error'),
            );
          },
        ),
      ),
      isExpanded: false,
    );
  }

  ExpansionPanel _buildInventoryPanel(BuildContext context) {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) => ListTile(
        leading: const Icon(Icons.inventory, color: Colors.orange),
        title: const Text('المخزون'),
        trailing: Text(isExpanded ? '▲' : '▼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer(
          builder: (context, ref, child) {
            final stats = ref.watch(inventoryStatsProvider);
            return stats.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow('إجمالي القيمة', '${(data['totalValue'] as num).toStringAsFixed(2)} ل.س'),
                  _StatRow('عدد الأصناف', '${data['totalItems']}'),
                  _StatRow('أصناف منخفضة المخزون', '${data['lowStockItems']}'),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('خطأ: $error'),
            );
          },
        ),
      ),
      isExpanded: false,
    );
  }

  ExpansionPanel _buildManufacturingPanel(BuildContext context) {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) => ListTile(
        leading: const Icon(Icons.precision_manufacturing, color: Colors.purple),
        title: const Text('الإنتاج'),
        trailing: Text(isExpanded ? '▲' : '▼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer(
          builder: (context, ref, child) {
            final stats = ref.watch(manufacturingStatsProvider);
            return stats.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow('إجمالي أوامر الإنتاج', '${data['totalOrders']}'),
                  _StatRow('الأوامر المنجزة', '${data['completedOrders']}'),
                  _StatRow('الأوامر قيد التنفيذ', '${data['inProgressOrders']}'),
                  _StatRow('نسبة الإنجاز', '${(data['completionRate'] as num).toStringAsFixed(1)}%'),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('خطأ: $error'),
            );
          },
        ),
      ),
      isExpanded: false,
    );
  }

  ExpansionPanel _buildHRPanel(BuildContext context) {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) => ListTile(
        leading: const Icon(Icons.people, color: Colors.red),
        title: const Text('الموارد البشرية'),
        trailing: Text(isExpanded ? '▲' : '▼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer(
          builder: (context, ref, child) {
            final stats = ref.watch(hrStatsProvider);
            return stats.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow('عدد الموظفين', '${data['totalEmployees']}'),
                  _StatRow('إجمالي الرواتب', '${(data['totalSalaries'] as num).toStringAsFixed(2)} ل.س'),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('خطأ: $error'),
            );
          },
        ),
      ),
      isExpanded: false,
    );
  }

  ExpansionPanel _buildFixedAssetsPanel(BuildContext context) {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) => ListTile(
        leading: const Icon(Icons.business, color: Colors.teal),
        title: const Text('الأصول الثابتة'),
        trailing: Text(isExpanded ? '▲' : '▼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer(
          builder: (context, ref, child) {
            final stats = ref.watch(fixedAssetsStatsProvider);
            return stats.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow('عدد الأصول', '${data['totalAssets']}'),
                  _StatRow('إجمالي التكلفة', '${(data['totalCost'] as num).toStringAsFixed(2)} ل.س'),
                  _StatRow('الإهلاك المتراكم', '${(data['accumulatedDepreciation'] as num).toStringAsFixed(2)} ل.س'),
                  _StatRow('صافي القيمة الدفترية', '${(data['netBookValue'] as num).toStringAsFixed(2)} ل.س'),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('خطأ: $error'),
            );
          },
        ),
      ),
      isExpanded: false,
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _AlertItem({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
