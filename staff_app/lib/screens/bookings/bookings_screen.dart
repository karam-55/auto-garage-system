import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/service_provider.dart';
import '../../models/booking.dart';
import '../../models/booking_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BookingProvider>().fetchBookings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحجوزات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBookingDialog(context),
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.bookings.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات'));
          }

          return ListView.builder(
            itemCount: provider.bookings.length,
            itemBuilder: (context, index) {
              final booking = provider.bookings[index];
              return _buildBookingCard(booking, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, BookingProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(booking.publicToken.substring(0, 2)),
        ),
        title: Text('حجز #${booking.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحالة: ${booking.statusDisplay}'),
            if (booking.notes != null) Text('ملاحظات: ${booking.notes}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showBookingDetails(context, booking),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBookingDialog(BuildContext context) {
    String? selectedCustomerId;
    String? selectedVehicleId;
    final notesController = TextEditingController();
    final List<Map<String, dynamic>> selectedServices = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إنشاء حجز جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<CustomerProvider>(
                  builder: (context, customerProvider, child) {
                    if (customerProvider.customers.isEmpty) {
                      Future.microtask(() => customerProvider.fetchCustomers());
                    }
                    return DropdownButtonFormField<String>(
                      hint: const Text('اختر العميل'),
                      items: customerProvider.customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer.id,
                          child: Text(customer.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedCustomerId = value);
                      },
                    );
                  },
                ),
                Consumer<VehicleProvider>(
                  builder: (context, vehicleProvider, child) {
                    if (vehicleProvider.vehicles.isEmpty) {
                      Future.microtask(() => vehicleProvider.fetchVehicles());
                    }
                    return DropdownButtonFormField<String>(
                      hint: const Text('اختر السيارة'),
                      items: vehicleProvider.vehicles.map((vehicle) {
                        return DropdownMenuItem(
                          value: vehicle.id,
                          child: Text(vehicle.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedVehicleId = value);
                      },
                    );
                  },
                ),
                const Text('الخدمات:', style: TextStyle(fontWeight: FontWeight.bold)),
                Consumer<ServiceProvider>(
                  builder: (context, serviceProvider, child) {
                    if (serviceProvider.services.isEmpty) {
                      Future.microtask(() => serviceProvider.fetchServices());
                    }
                    return Column(
                      children: serviceProvider.services.map((service) {
                        return CheckboxListTile(
                          title: Text(service.name),
                          subtitle: Text('${service.priceSYP} ل.س'),
                          value: selectedServices.any((s) => s['serviceId'] == service.id),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selectedServices.add({
                                  'serviceId': service.id,
                                  'priceSYP': service.priceSYP,
                                });
                              } else {
                                selectedServices.removeWhere((s) => s['serviceId'] == service.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCustomerId == null || selectedVehicleId == null || selectedServices.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة')),
                  );
                  return;
                }
                final bookingData = {
                  'customerId': selectedCustomerId,
                  'vehicleId': selectedVehicleId,
                  'services': selectedServices,
                  'notes': notesController.text.isEmpty ? null : notesController.text,
                };
                final success = await context.read<BookingProvider>().createBooking(bookingData);
                if (success && mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الحجز #${booking.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الحالة: ${booking.statusDisplay}'),
              const SizedBox(height: 8),
              Text('رمز التتبع: ${booking.publicToken}'),
              const SizedBox(height: 8),
              if (booking.notes != null) Text('ملاحظات: ${booking.notes}'),
              const SizedBox(height: 8),
              Text('تاريخ الإنشاء: ${booking.createdAt.toString()}'),
              const SizedBox(height: 16),
              const Text('الخدمات:', style: TextStyle(fontWeight: FontWeight.bold)),
              FutureBuilder(
                future: context.read<BookingProvider>().fetchBookingServices(booking.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final bookingServices = context.read<BookingProvider>().bookingServices;
                  return Column(
                    children: bookingServices.map((service) {
                      return ListTile(
                        title: Text('خدمة #${service.serviceId}'),
                        subtitle: Text('${service.priceSYP} ل.س'),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
