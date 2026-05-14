import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/mechanic_provider.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Booking booking;

  const VehicleDetailScreen({super.key, required this.booking});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MechanicProvider>().fetchPartSuggestions(widget.booking.id);
    });
  }

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
            if (widget.booking.vehicle != null) ...[
              _buildSection('معلومات السيارة', [
                _buildDetailRow('الماركة', widget.booking.vehicle!.make),
                _buildDetailRow('الموديل', widget.booking.vehicle!.model),
                if (widget.booking.vehicle!.year != null)
                  _buildDetailRow('السنة', widget.booking.vehicle!.year.toString()),
                if (widget.booking.vehicle!.licensePlate != null)
                  _buildDetailRow('رقم اللوحة', widget.booking.vehicle!.licensePlate!),
              ]),
            ],
            const SizedBox(height: 16),
            if (widget.booking.customer != null) ...[
              _buildSection('معلومات العميل', [
                _buildDetailRow('الاسم', widget.booking.customer!.fullName),
                if (widget.booking.customer!.phone != null)
                  _buildDetailRow('الهاتف', widget.booking.customer!.phone!),
              ]),
            ],
            const SizedBox(height: 16),
            _buildSection('معلومات الحجز', [
              _buildDetailRow('الحالة', _getStatusText(widget.booking.status)),
              _buildDetailRow('تاريخ الإنشاء', _formatDate(widget.booking.createdAt)),
              if (widget.booking.estimatedCompletionDate != null)
                _buildDetailRow('تاريخ الانتهاء المتوقع', _formatDate(widget.booking.estimatedCompletionDate!)),
              if (widget.booking.notes != null && widget.booking.notes!.isNotEmpty)
                _buildDetailRow('الملاحظات', widget.booking.notes!),
            ]),
            const SizedBox(height: 24),
            const Text(
              'خيارات القطع المقترحة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer<MechanicProvider>(
              builder: (context, mechanicProvider, child) {
                if (mechanicProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (mechanicProvider.partSuggestions.isEmpty) {
                  return const Text('لا توجد قطع مقترحة بعد');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mechanicProvider.partSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = mechanicProvider.partSuggestions[index];
                    return Card(
                      child: ListTile(
                        title: Text(_getPartTypeText(suggestion.type)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(suggestion.description),
                            if (suggestion.priceSYP != null)
                              Text('السعر: ${suggestion.priceSYP} ل.س'),
                            Text('الحالة: ${_getSuggestionStatusText(suggestion.status)}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _showAddPartSuggestionDialog(context);
              },
              child: const Text('إضافة اقتراح قطعة'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _showConsumePartsDialog(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('استهلاك قطع من المخزون'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _showInvoiceDialog(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('عرض الفاتورة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'قيد الانتظار';
      case 'IN_PROGRESS':
        return 'قيد العمل';
      case 'COMPLETED':
        return 'مكتمل';
      case 'CANCELLED':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _getPartTypeText(String type) {
    switch (type) {
      case 'ORIGINAL':
        return 'أصلي';
      case 'AFTERMARKET':
        return 'تجاري';
      case 'USED':
        return 'مستعمل';
      default:
        return type;
    }
  }

  String _getSuggestionStatusText(String status) {
    switch (status) {
      case 'PENDING_CUSTOMER_APPROVAL':
        return 'بانتظار موافقة العميل';
      case 'APPROVED':
        return 'موافق عليه';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddPartSuggestionDialog(BuildContext context) {
    final typeController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة اقتراح قطعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'نوع القطعة'),
              items: const [
                DropdownMenuItem(value: 'ORIGINAL', child: Text('أصلي')),
                DropdownMenuItem(value: 'AFTERMARKET', child: Text('تجاري')),
                DropdownMenuItem(value: 'USED', child: Text('مستعمل')),
              ],
              onChanged: (value) => typeController.text = value ?? '',
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'السعر (ل.س)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final mechanicProvider = context.read<MechanicProvider>();
              final success = await mechanicProvider.createPartSuggestion(
                widget.booking.id,
                typeController.text,
                descriptionController.text,
                double.tryParse(priceController.text),
              );
              if (success && mounted) {
                Navigator.pop(context);
                await mechanicProvider.fetchPartSuggestions(widget.booking.id);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showConsumePartsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استهلاك قطع من المخزون'),
        content: FutureBuilder(
          future: context.read<MechanicProvider>().fetchInventory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final inventory = snapshot.data;
            if (inventory == null || inventory.isEmpty) {
              return const Text('المخزون فارغ أو لا توجد قطع متاحة');
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['name'] ?? 'غير معروف'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الكمية: ${item['quantity'] ?? 0}'),
                          Text('سعر البيع: ${item['sellingPrice'] ?? 0} ل.س'),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _showConsumeQuantityDialog(context, item);
                        },
                        child: const Text('استهلاك'),
                      ),
                    ),
                  );
                },
              ),
            );
          },
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

  void _showConsumeQuantityDialog(BuildContext context, Map<String, dynamic> item) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('استهلاك ${item['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الكمية المتاحة: ${item['quantity'] ?? 0}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'الكمية'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text);
              if (quantity != null && quantity > 0) {
                final mechanicProvider = context.read<MechanicProvider>();
                final success = await mechanicProvider.consumePart(
                  item['id'],
                  quantity,
                  widget.booking.id,
                );
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم استهلاك القطع بنجاح')),
                  );
                }
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فاتورة الحجز'),
        content: FutureBuilder(
          future: context.read<MechanicProvider>().fetchInvoice(widget.booking.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Text('خطأ في تحميل الفاتورة: ${snapshot.error}');
            }
            
            final invoice = snapshot.data;
            if (invoice == null) {
              return const Text('لا توجد فاتورة لهذا الحجز');
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('رقم الحجز: ${widget.booking.id}'),
                  const SizedBox(height: 8),
                  Text('الإجمالي: ${invoice['totalPrice'] ?? 0} ل.س'),
                  const SizedBox(height: 8),
                  Text('تاريخ الإنشاء: ${invoice['invoiceCreatedAt'] ?? ''}'),
                  const SizedBox(height: 16),
                  if (invoice['servicesSnapshot'] != null)
                    const Text('الخدمات:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (invoice['partsSnapshot'] != null)
                    const Text('القطع:', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
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
