import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mechanic_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking.dart';
import '../vehicle_detail/vehicle_detail_screen.dart';

class AvailableBookingsScreen extends StatefulWidget {
  const AvailableBookingsScreen({super.key});

  @override
  State<AvailableBookingsScreen> createState() => _AvailableBookingsScreenState();
}

class _AvailableBookingsScreenState extends State<AvailableBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MechanicProvider>().fetchAvailableBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السيارات المتاحة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.pushNamed(context, '/my-assignments');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Consumer<MechanicProvider>(
        builder: (context, mechanicProvider, child) {
          if (mechanicProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mechanicProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(mechanicProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      mechanicProvider.fetchAvailableBookings();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (mechanicProvider.availableBookings.isEmpty) {
            return const Center(
              child: Text('لا توجد سيارات متاحة حالياً'),
            );
          }

          return ListView.builder(
            itemCount: mechanicProvider.availableBookings.length,
            itemBuilder: (context, index) {
              final booking = mechanicProvider.availableBookings[index];
              return _buildBookingCard(booking, mechanicProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, MechanicProvider mechanicProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(booking.vehicle?.displayName[0] ?? '?'),
        ),
        title: Text(booking.vehicle?.displayName ?? 'غير معروف'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (booking.vehicle?.licensePlate != null)
              Text('رقم اللوحة: ${booking.vehicle!.licensePlate}'),
            if (booking.customer?.fullName != null)
              Text('العميل: ${booking.customer!.fullName}'),
            if (booking.notes != null && booking.notes!.isNotEmpty)
              Text('الملاحظات: ${booking.notes}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('تأكيد استلام السيارة'),
                content: Text('هل تريد استلام سيارة ${booking.vehicle?.displayName}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('تأكيد'),
                  ),
                ],
              ),
            );

            if (confirmed == true && mounted) {
              await mechanicProvider.assignBooking(booking.id);
            }
          },
          child: const Text('استلام'),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailScreen(booking: booking),
            ),
          );
        },
      ),
    );
  }
}
