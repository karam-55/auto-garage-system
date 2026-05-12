import 'package:flutter/material.dart';
import '../core/widgets/animated_card.dart';
import '../core/widgets/loading_screen.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class ServicesScreen extends StatefulWidget {
  final ApiService apiService;

  const ServicesScreen({super.key, required this.apiService});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.services);
      setState(() {
        final raw = response is List ? response : (response['data'] ?? []);
        _services = List<Map<String, dynamic>>.from(raw);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الخدمات: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;
    return _services.where((service) {
      final name = service['name']?.toString().toLowerCase() ?? '';
      final description = service['description']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) ||
          description.contains(_searchQuery.toLowerCase());
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
                : _services.isEmpty
                    ? _buildEmptyState()
                    : _buildServicesGrid(),
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
              'إدارة الخدمات',
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
                hintText: 'بحث خدمة...',
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
            onPressed: () => _showAddServiceDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة خدمة'),
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
            Icons.build_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات حالياً',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "إضافة خدمة" لإنشاء خدمة جديدة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddServiceDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة خدمة'),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 800
                ? 2
                : 1;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: _filteredServices.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: AnimatedServiceCard(
                      name: _filteredServices[index]['name'] ?? '',
                      description: _filteredServices[index]['description'] ?? '',
                      price: (_filteredServices[index]['priceSYP'] as num?)?.toDouble() ?? 0.0,
                      onEdit: () => _showEditServiceDialog(context, _filteredServices[index]),
                      onDelete: () => _deleteService(_filteredServices[index]['id']),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة خدمة جديدة'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم الخدمة'),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'السعر (ل.س)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'المدة المقدرة (دقائق)'),
                  keyboardType: TextInputType.number,
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
                  await widget.apiService.post(ApiConstants.services, {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'priceSYP': double.parse(priceController.text),
                    'estimatedDurationMinutes': durationController.text.isEmpty 
                        ? null 
                        : int.parse(durationController.text),
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    _loadServices();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة الخدمة بنجاح'),
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

  void _showEditServiceDialog(BuildContext context, Map<String, dynamic> service) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: service['name'] ?? '');
    final descriptionController = TextEditingController(text: service['description'] ?? '');
    final priceController = TextEditingController(text: service['priceSYP']?.toString() ?? '');
    final durationController = TextEditingController(text: service['estimatedDurationMinutes']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الخدمة'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم الخدمة'),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'السعر (ل.س)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'المدة المقدرة (دقائق)'),
                  keyboardType: TextInputType.number,
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
                    '${ApiConstants.services}/${service['id']}',
                    body: {
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'priceSYP': double.parse(priceController.text),
                      'estimatedDurationMinutes': durationController.text.isEmpty 
                          ? null 
                          : int.parse(durationController.text),
                    },
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _loadServices();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث الخدمة بنجاح'),
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

  Future<void> _deleteService(String? id) async {
    if (id == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الخدمة؟'),
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
        await widget.apiService.delete('${ApiConstants.services}/$id');
        _loadServices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الخدمة بنجاح'),
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
}
