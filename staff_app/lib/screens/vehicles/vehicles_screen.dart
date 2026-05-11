import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/vehicle.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VehicleProvider>().fetchVehicles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السيارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddVehicleDialog(context),
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.vehicles.isEmpty) {
            return const Center(child: Text('لا توجد سيارات'));
          }

          return ListView.builder(
            itemCount: provider.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = provider.vehicles[index];
              return _buildVehicleCard(vehicle, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle, VehicleProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.directions_car),
        title: Text(vehicle.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicle.licensePlate != null) Text('لوحة: ${vehicle.licensePlate}'),
            if (vehicle.vin != null) Text('VIN: ${vehicle.vin}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditVehicleDialog(context, vehicle, provider),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    final makeController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final licensePlateController = TextEditingController();
    final vinController = TextEditingController();
    String? selectedCustomerId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة سيارة جديدة'),
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
                    onChanged: (value) => selectedCustomerId = value,
                  );
                },
              ),
              TextField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'الماركة'),
              ),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'الموديل'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'السنة'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(labelText: 'رقم اللوحة'),
              ),
              TextField(
                controller: vinController,
                decoration: const InputDecoration(labelText: 'VIN'),
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
              if (selectedCustomerId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء اختيار العميل')),
                );
                return;
              }
              final vehicle = Vehicle(
                id: '',
                customerId: selectedCustomerId!,
                make: makeController.text,
                model: modelController.text,
                year: int.parse(yearController.text),
                licensePlate: licensePlateController.text.isEmpty ? null : licensePlateController.text,
                vin: vinController.text.isEmpty ? null : vinController.text,
                createdAt: DateTime.now(),
              );
              final success = await context.read<VehicleProvider>().createVehicle(vehicle);
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditVehicleDialog(BuildContext context, Vehicle vehicle, VehicleProvider provider) {
    final makeController = TextEditingController(text: vehicle.make);
    final modelController = TextEditingController(text: vehicle.model);
    final yearController = TextEditingController(text: vehicle.year.toString());
    final licensePlateController = TextEditingController(text: vehicle.licensePlate ?? '');
    final vinController = TextEditingController(text: vehicle.vin ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل السيارة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'الماركة'),
              ),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'الموديل'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'السنة'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(labelText: 'رقم اللوحة'),
              ),
              TextField(
                controller: vinController,
                decoration: const InputDecoration(labelText: 'VIN'),
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
              final updatedVehicle = vehicle.copyWith(
                make: makeController.text,
                model: modelController.text,
                year: int.parse(yearController.text),
                licensePlate: licensePlateController.text.isEmpty ? null : licensePlateController.text,
                vin: vinController.text.isEmpty ? null : vinController.text,
                updatedAt: DateTime.now(),
              );
              final success = await provider.updateVehicle(updatedVehicle);
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
