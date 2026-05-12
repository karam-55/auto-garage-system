import 'package:flutter/material.dart';
import '../core/widgets/animated_card.dart';
import '../core/widgets/loading_screen.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class EmployeesScreen extends StatefulWidget {
  final ApiService apiService;

  const EmployeesScreen({super.key, required this.apiService});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<dynamic> _employees = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.users);
      setState(() {
        final raw = response is List ? response : (response['data'] ?? []);
        _employees = List<Map<String, dynamic>>.from(raw);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الموظفين: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredEmployees {
    if (_searchQuery.isEmpty) return _employees;
    return _employees.where((employee) {
      final name = employee['fullName']?.toString().toLowerCase() ?? '';
      final username = employee['username']?.toString().toLowerCase() ?? '';
      final role = employee['role']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) ||
          username.contains(_searchQuery.toLowerCase()) ||
          role.contains(_searchQuery.toLowerCase());
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
                : _employees.isEmpty
                    ? _buildEmptyState()
                    : _buildEmployeesList(),
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
              'إدارة الموظفين',
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
                hintText: 'بحث موظف...',
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
            onPressed: () => _showAddEmployeeDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة موظف'),
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
            Icons.work_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد موظفين حالياً',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "إضافة موظف" لإنشاء موظف جديد',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEmployeeDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة موظف'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildEmployeeCard(_filteredEmployees[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeCard(dynamic employee) {
    final role = employee['role'] as String? ?? '';
    final roleColor = _getRoleColor(role);
    final isActive = employee['isActive'] as bool? ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Theme.of(context).dividerColor : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.1),
          child: Text(
            (employee['fullName'] as String? ?? '?')[0].toUpperCase(),
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          employee['fullName'] ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee['username'] ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getRoleText(role),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 16,
                  color: isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? 'نشط' : 'غير نشط',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isActive ? Colors.green : Colors.red,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _showEditEmployeeDialog(context, employee),
            ),
            IconButton(
              icon: Icon(isActive ? Icons.block_rounded : Icons.check_circle_rounded),
              color: isActive ? Colors.orange : Colors.green,
              onPressed: () => _toggleEmployeeStatus(employee),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              color: Colors.red,
              onPressed: () => _deleteEmployee(employee['id']),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return Colors.purple;
      case 'MANAGER':
        return Colors.blue;
      case 'RECEPTIONIST':
        return Colors.green;
      case 'MECHANIC':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRoleText(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return 'مالك';
      case 'MANAGER':
        return 'مدير';
      case 'RECEPTIONIST':
        return 'استقبال';
      case 'MECHANIC':
        return 'ميكانيكي';
      default:
        return role;
    }
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'MECHANIC';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة موظف جديد'),
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
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'كلمة المرور (12 حرف على الأقل، حرف كبير، حرف صغير، رقم، رمز خاص)'),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'مطلوب';
                    if (value!.length < 12) return 'يجب أن تكون كلمة المرور 12 حرف على الأقل';
                    if (!value.contains(RegExp(r'[A-Z]'))) return 'يجب أن تحتوي على حرف كبير';
                    if (!value.contains(RegExp(r'[a-z]'))) return 'يجب أن تحتوي على حرف صغير';
                    if (!value.contains(RegExp(r'[0-9]'))) return 'يجب أن تحتوي على رقم';
                    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return 'يجب أن تحتوي على رمز خاص';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'الصلاحية'),
                  items: const [
                    DropdownMenuItem(value: 'OWNER', child: Text('مالك')),
                    DropdownMenuItem(value: 'MANAGER', child: Text('مدير')),
                    DropdownMenuItem(value: 'RECEPTIONIST', child: Text('استقبال')),
                    DropdownMenuItem(value: 'MECHANIC', child: Text('ميكانيكي')),
                  ],
                  onChanged: (value) => setState(() => selectedRole = value!),
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
                  await widget.apiService.post(ApiConstants.register, {
                    'fullName': fullNameController.text,
                    'username': usernameController.text,
                    'password': passwordController.text,
                    'role': selectedRole,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    _loadEmployees();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة الموظف بنجاح'),
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

  void _showEditEmployeeDialog(BuildContext context, dynamic employee) {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController(text: employee['fullName'] ?? '');
    final usernameController = TextEditingController(text: employee['username'] ?? '');
    String selectedRole = employee['role'] ?? 'MECHANIC';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الموظف'),
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
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'الصلاحية'),
                  items: const [
                    DropdownMenuItem(value: 'OWNER', child: Text('مالك')),
                    DropdownMenuItem(value: 'MANAGER', child: Text('مدير')),
                    DropdownMenuItem(value: 'RECEPTIONIST', child: Text('استقبال')),
                    DropdownMenuItem(value: 'MECHANIC', child: Text('ميكانيكي')),
                  ],
                  onChanged: (value) => setState(() => selectedRole = value!),
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
                    '${ApiConstants.users}/${employee['id']}',
                    body: {
                      'fullName': fullNameController.text,
                      'username': usernameController.text,
                      'role': selectedRole,
                    },
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _loadEmployees();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث الموظف بنجاح'),
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

  Future<void> _toggleEmployeeStatus(dynamic employee) async {
    try {
      await widget.apiService.patch(
        '${ApiConstants.users}/${employee['id']}',
        body: {'isActive': !(employee['isActive'] as bool? ?? true)},
      );
      _loadEmployees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              employee['isActive'] == true
                  ? 'تم تعطيل الموظف'
                  : 'تم تفعيل الموظف',
            ),
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

  Future<void> _deleteEmployee(String? id) async {
    if (id == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الموظف؟'),
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
        await widget.apiService.delete('${ApiConstants.users}/$id');
        _loadEmployees();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الموظف بنجاح'),
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
