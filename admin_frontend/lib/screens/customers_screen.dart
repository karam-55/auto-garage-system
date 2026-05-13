import 'package:flutter/material.dart';
import '../core/widgets/loading_screen.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../core/widgets/professional_dialog.dart';

class CustomersScreen extends StatefulWidget {
  final ApiService apiService;

  const CustomersScreen({super.key, required this.apiService});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<dynamic> _customers = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.customers);
      setState(() {
        final raw = response is List ? response : (response['data'] ?? []);
        _customers = List<Map<String, dynamic>>.from(raw);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل العملاء: $e')));
      }
    }
  }

  List<dynamic> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((customer) {
      final name = customer['fullName']?.toString().toLowerCase() ?? '';
      final phone = customer['phone']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionLoading(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _customers.isEmpty
                      ? _buildEmptyState()
                      : _buildCustomersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 600;

    return isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إدارة العملاء',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildSearchField(),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddCustomerDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('إضافة عميل'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: Text(
                  'إدارة العملاء',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(width: 280, child: _buildSearchField()),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddCustomerDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('إضافة عميل'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'بحث عميل...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا يوجد عملاء حالياً', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('اضغط على "إضافة عميل" لإنشاء عميل جديد', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddCustomerDialog(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('إضافة عميل'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
                ? 2
                : 1;

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _filteredCustomers.length,
          itemBuilder: (context, index) {
            return _CustomerCard(
              customer: _filteredCustomers[index],
              onTap: () => _showCustomerDetailsDialog(context, _filteredCustomers[index]),
              onDelete: () => _deleteCustomer(_filteredCustomers[index]['id']),
            );
          },
        );
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showProfessionalDialog(
      context: context,
      title: 'إضافة عميل جديد',
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      onConfirm: () async {
        if (formKey.currentState?.validate() ?? false) {
          try {
            await widget.apiService.post(ApiConstants.customers, {
              'fullName': fullNameController.text,
              'phone': phoneController.text,
              'address': addressController.text,
            });
            if (mounted) {
              Navigator.pop(context);
              _loadCustomers();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة العميل بنجاح')));
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
            }
          }
        }
      },
    );
  }

  void _showCustomerDetailsDialog(BuildContext context, dynamic customer) {
    showProfessionalDialog(
      context: context,
      title: 'تفاصيل العميل',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('الاسم الكامل', customer['fullName'] ?? ''),
          const SizedBox(height: 8),
          _buildDetailRow('رقم الهاتف', customer['phone'] ?? ''),
          const SizedBox(height: 8),
          _buildDetailRow('العنوان', customer['address'] ?? 'غير محدد'),
          const SizedBox(height: 8),
          _buildDetailRow('تاريخ الإنشاء', _formatDate(customer['createdAt'])),
        ],
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _showEditCustomerDialog(context, customer);
          },
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: const Text('تعديل'),
        ),
      ],
    );
  }

  void _showEditCustomerDialog(BuildContext context, dynamic customer) {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController(text: customer['fullName'] ?? '');
    final phoneController = TextEditingController(text: customer['phone'] ?? '');
    final addressController = TextEditingController(text: customer['address'] ?? '');

    showProfessionalDialog(
      context: context,
      title: 'تعديل العميل',
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      onConfirm: () async {
        if (formKey.currentState?.validate() ?? false) {
          try {
            await widget.apiService.patch(
              '${ApiConstants.customers}/${customer['id']}',
              body: {
                'fullName': fullNameController.text,
                'phone': phoneController.text,
                'address': addressController.text,
              },
            );
            if (mounted) {
              Navigator.pop(context);
              _loadCustomers();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث العميل بنجاح')));
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
            }
          }
        }
      },
    );
  }

  Future<void> _deleteCustomer(String? id) async {
    if (id == null) return;

    final confirmed = await showProfessionalDialog<bool>(
      context: context,
      title: 'تأكيد الحذف',
      content: const Text('هل أنت متأكد من حذف هذا العميل؟'),
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      onConfirm: () => Navigator.pop(context, true),
    );

    if (confirmed == true) {
      try {
        await widget.apiService.delete('${ApiConstants.customers}/$id');
        _loadCustomers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف العميل بنجاح')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
        }
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    if (date is String) {
      try {
        final dateTime = DateTime.parse(date);
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } catch (e) {
        return date;
      }
    }
    return date.toString();
  }
}

class _CustomerCard extends StatelessWidget {
  final dynamic customer;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustomerCard({required this.customer, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_rounded, color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customer['fullName'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          _buildInfoRow('رقم الهاتف', customer['phone'] ?? 'غير متوفر'),
          const SizedBox(height: 8),
          _buildInfoRow('العنوان', customer['address'] ?? 'غير محدد'),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.info_outline_rounded, size: 16),
            label: const Text('التفاصيل'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
