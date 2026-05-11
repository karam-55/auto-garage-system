import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mechanic_provider.dart';
import '../../models/booking.dart';

class AvailableBookingsScreen extends StatefulWidget {
  const AvailableBookingsScreen({super.key});

  @override
  State<AvailableBookingsScreen> createState() => _AvailableBookingsScreenState();
}

class _AvailableBookingsScreenState extends State<AvailableBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MechanicProvider>().fetchAvailableBookings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحجوزات المتاحة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MechanicProvider>().fetchAvailableBookings(),
          ),
        ],
      ),
      body: Consumer<MechanicProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.availableBookings.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات متاحة'));
          }

          return ListView.builder(
            itemCount: provider.availableBookings.length,
            itemBuilder: (context, index) {
              final booking = provider.availableBookings[index];
              return _buildBookingCard(booking, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, MechanicProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(booking.id.substring(0, 2)),
        ),
        title: Text('حجز #${booking.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحالة: ${booking.statusDisplay}'),
            Text('العميل: ${booking.customerId}'),
            Text('السيارة: ${booking.vehicleId}'),
            if (booking.notes != null) Text('ملاحظات: ${booking.notes}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _showAssignConfirmation(context, booking, provider),
          child: const Text('استلام'),
        ),
      ),
    );
  }

  void _showAssignConfirmation(BuildContext context, Booking booking, MechanicProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد استلام الحجز'),
        content: Text('هل تريد استلام الحجز #${booking.id.substring(0, 8)}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.assignBooking(booking.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم استلام الحجز بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
