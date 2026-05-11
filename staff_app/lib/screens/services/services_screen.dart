import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../models/service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ServiceProvider>().fetchServices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخدمات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(context),
          ),
        ],
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.services.isEmpty) {
            return const Center(child: Text('لا توجد خدمات'));
          }

          return ListView.builder(
            itemCount: provider.services.length,
            itemBuilder: (context, index) {
              final service = provider.services[index];
              return _buildServiceCard(service, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(Service service, ServiceProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.build_circle),
        title: Text(service.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${service.priceSYP.toString()} ل.س'),
            if (service.description != null) Text(service.description!),
            if (service.estimatedDurationMinutes != null)
              Text('المدة المقدرة: ${service.estimatedDurationMinutes} دقيقة'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditServiceDialog(context, service, provider),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة خدمة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الخدمة'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر (ل.س)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'المدة المقدرة (دقيقة)'),
                keyboardType: TextInputType.number,
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
              final service = Service(
                id: '',
                name: nameController.text,
                description: descriptionController.text.isEmpty ? null : descriptionController.text,
                priceSYP: double.parse(priceController.text),
                estimatedDurationMinutes: durationController.text.isEmpty ? null : int.parse(durationController.text),
                createdAt: DateTime.now(),
              );
              final success = await context.read<ServiceProvider>().createService(service);
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

  void _showEditServiceDialog(BuildContext context, Service service, ServiceProvider provider) {
    final nameController = TextEditingController(text: service.name);
    final descriptionController = TextEditingController(text: service.description ?? '');
    final priceController = TextEditingController(text: service.priceSYP.toString());
    final durationController = TextEditingController(text: service.estimatedDurationMinutes?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الخدمة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الخدمة'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر (ل.س)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'المدة المقدرة (دقيقة)'),
                keyboardType: TextInputType.number,
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
              final updatedService = service.copyWith(
                name: nameController.text,
                description: descriptionController.text.isEmpty ? null : descriptionController.text,
                priceSYP: double.parse(priceController.text),
                estimatedDurationMinutes: durationController.text.isEmpty ? null : int.parse(durationController.text),
                updatedAt: DateTime.now(),
              );
              final success = await provider.updateService(updatedService);
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
