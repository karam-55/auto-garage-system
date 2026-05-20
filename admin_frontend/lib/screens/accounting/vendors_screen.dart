import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/financial_providers.dart';
import '../../core/services/api_service.dart';

class VendorsScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const VendorsScreen({super.key, required this.apiService});

  @override
  ConsumerState<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends ConsumerState<VendorsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموردين'),
      ),
      body: ref.watch(vendorsProvider).when(
        data: (vendors) {
          if (vendors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد موردين',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return DataTable(
            columns: const [
              DataColumn(label: Text('الاسم')),
              DataColumn(label: Text('الهاتف')),
              DataColumn(label: Text('العنوان')),
              DataColumn(label: Text('الرقم الضريبي')),
              DataColumn(label: Text('')),
            ],
            rows: vendors.map<DataRow>((vendor) {
              return DataRow(cells: [
                DataCell(Text(vendor['name'] as String)),
                DataCell(Text(vendor['phone']?.toString() ?? '-')),
                DataCell(Text(vendor['address']?.toString() ?? '-')),
                DataCell(Text(vendor['tax_number']?.toString() ?? '-')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editVendor(vendor),
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteVendor(vendor['id'] as int),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('خطأ في تحميل البيانات: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVendor,
        child: const Icon(Icons.add),
        tooltip: 'إضافة مورد',
      ),
    );
  }

  void _addVendor() {
    _showVendorDialog();
  }

  void _editVendor(Map<String, dynamic> vendor) {
    _showVendorDialog(vendor: vendor);
  }

  Future<void> _deleteVendor(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المورد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(deleteVendorProvider(id).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المورد بنجاح')),
        );
      }
      ref.invalidate(vendorsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حذف المورد: $e')),
        );
      }
    }
  }

  Future<void> _showVendorDialog({Map<String, dynamic>? vendor}) async {
    final nameController = TextEditingController(text: vendor?['name']?.toString() ?? '');
    final phoneController = TextEditingController(text: vendor?['phone']?.toString() ?? '');
    final addressController = TextEditingController(text: vendor?['address']?.toString() ?? '');
    final taxNumberController = TextEditingController(text: vendor?['tax_number']?.toString() ?? '');

    final isEditing = vendor != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'تعديل مورد' : 'إضافة مورد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'الهاتف',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: taxNumberController,
                decoration: const InputDecoration(
                  labelText: 'الرقم الضريبي',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      if (isEditing) {
        await widget.apiService.put('/api/vendors/${vendor!['id']}', {
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'tax_number': taxNumberController.text,
        });
      } else {
        await ref.read(createVendorProvider({
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'tax_number': taxNumberController.text,
        }).future);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'تم تعديل المورد بنجاح' : 'تم إضافة المورد بنجاح')),
        );
      }

      ref.invalidate(vendorsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }

    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    taxNumberController.dispose();
  }
}
