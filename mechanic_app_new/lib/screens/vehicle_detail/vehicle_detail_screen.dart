import 'package:flutter/material.dart';
import '../../domain/entities/booking.dart';
import '../consume_part/consume_part_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Booking booking;

  const VehicleDetailScreen({super.key, required this.booking});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل السيارة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('معلومات السيارة', [
              _buildDetailRow('الماركة', widget.booking.vehicle.make),
              _buildDetailRow('الموديل', widget.booking.vehicle.model),
              if (widget.booking.vehicle.year != null)
                _buildDetailRow('السنة', widget.booking.vehicle.year.toString()),
              if (widget.booking.vehicle.licensePlate != null)
                _buildDetailRow('رقم اللوحة', widget.booking.vehicle.licensePlate!),
            ]),
            const SizedBox(height: 16),
            _buildSection('معلومات العميل', [
              _buildDetailRow('الاسم', widget.booking.customer.fullName),
              if (widget.booking.customer.phone != null)
                _buildDetailRow('الهاتف', widget.booking.customer.phone!),
              if (widget.booking.customer.address != null)
                _buildDetailRow('العنوان', widget.booking.customer.address!),
            ]),
            const SizedBox(height: 16),
            _buildSection('معلومات الحجز', [
              _buildDetailRow('الحالة', widget.booking.status),
              _buildDetailRow('تاريخ الإنشاء', widget.booking.createdAt.toString().split('.')[0]),
              if (widget.booking.notes != null && widget.booking.notes!.isNotEmpty)
                _buildDetailRow('الملاحظات', widget.booking.notes!),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConsumePartScreen(bookingId: widget.booking.id),
                    ),
                  );
                },
                icon: const Icon(Icons.inventory_2),
                label: const Text('استهلاك قطع'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
