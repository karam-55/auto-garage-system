import 'package:flutter/material.dart';
import '../core/widgets/animated_card.dart';
import '../core/widgets/loading_screen.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل العملاء: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((customer) {
      final name = customer['fullName']?.toString().toLowerCase() ?? '';
      final phone = customer['phone']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) ||
          phone.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionLoading(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _customers.isEmpty
                    ? _buildEmptyState()
                    : _buildCustomersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'إدارة العملاء',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث عميل...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddCustomerDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة عميل'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد عملاء حالياً',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "إضافة عميل" لإنشاء عميل جديد',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddCustomerDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة عميل'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: AnimatedCustomerTile(
                  name: _filteredCustomers[index]['fullName'] ?? '',
                  phone: _filteredCustomers[index]['phone'] ?? '',
                  address: _filteredCustomers[index]['address'],
                  onTap: () => _showCustomerDetailsDialog(context, _filteredCustomers[index]),
                  onDelete: () => _deleteCustomer(_filteredCustomers[index]['id']),
                ),
              ),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عميل جديد'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة العميل بنجاح'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetailsDialog(BuildContext context, dynamic customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل العميل'),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditCustomerDialog(context, customer);
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('تعديل'),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, dynamic customer) {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController(text: customer['fullName'] ?? '');
    final phoneController = TextEditingController(text: customer['phone'] ?? '');
    final addressController = TextEditingController(text: customer['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل العميل'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث العميل بنجاح'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(String? id) async {
    if (id == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العميل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.apiService.delete('${ApiConstants.customers}/$id');
        _loadCustomers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف العميل بنجاح'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
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
