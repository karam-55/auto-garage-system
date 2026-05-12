import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/constants/api_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  runApp(const AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام ورشة السيارات - لوحة التحكم',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _authService.login(
          _usernameController.text,
          _passwordController.text,
        );
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                token: _authService.token,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 64, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  'نظام ورشة السيارات',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'لوحة التحكم',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('تسجيل الدخول'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String? token;

  const DashboardScreen({super.key, this.token});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _apiService.setToken(widget.token);
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const OverviewScreen(),
      BookingsScreen(apiService: _apiService),
      CustomersScreen(apiService: _apiService),
      ServicesScreen(apiService: _apiService),
      EmployeesScreen(apiService: _apiService),
      const ReportsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام ورشة السيارات - لوحة التحكم'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('نظرة عامة'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('الحجوزات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people),
                label: Text('العملاء'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.build),
                selectedIcon: Icon(Icons.build),
                label: Text('الخدمات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work),
                selectedIcon: Icon(Icons.work),
                label: Text('الموظفين'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                selectedIcon: Icon(Icons.bar_chart),
                label: Text('التقارير'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Placeholder Screens
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'نظرة عامة على النظام',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('الإحصائيات والمؤشرات الرئيسية ستظهر هنا'),
        ],
      ),
    );
  }
}

class BookingsScreen extends StatefulWidget {
  final ApiService apiService;

  const BookingsScreen({super.key, required this.apiService});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.bookings);
      setState(() {
        // Backend returns array directly, not wrapped in {data: [...]}
        _bookings = response is List ? response : (response['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل الحجوزات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إدارة الحجوزات',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBookingDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة حجز'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('لا توجد حجوزات حالياً'),
                            SizedBox(height: 8),
                            Text('اضغط على "إضافة حجز" لإنشاء حجز جديد'),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return ListTile(
                            title: Text('حجز #${booking['id'] ?? ''}'),
                            subtitle: Text('الحالة: ${booking['status'] ?? ''}'),
                            trailing: Text('${booking['createdAt'] ?? ''}'),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  void _showAddBookingDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final customerIdController = TextEditingController();
    final vehicleIdController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة حجز جديد'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: customerIdController,
                decoration: const InputDecoration(labelText: 'معرف العميل'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: vehicleIdController,
                decoration: const InputDecoration(labelText: 'معرف المركبة'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
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
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await widget.apiService.post(ApiConstants.bookings, {
                    'customerId': customerIdController.text,
                    'vehicleId': vehicleIdController.text,
                    'notes': notesController.text,
                  });
                  Navigator.pop(context);
                  _loadBookings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة الحجز بنجاح')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $e')),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

class CustomersScreen extends StatefulWidget {
  final ApiService apiService;

  const CustomersScreen({super.key, required this.apiService});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<dynamic> _customers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.customers);
      setState(() {
        // Backend returns array directly, not wrapped in {data: [...]}
        _customers = response is List ? response : (response['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل العملاء: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إدارة العملاء',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddCustomerDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة عميل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _customers.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('لا يوجد عملاء حالياً'),
                            SizedBox(height: 8),
                            Text('اضغط على "إضافة عميل" لإنشاء عميل جديد'),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _customers.length,
                        itemBuilder: (context, index) {
                          final customer = _customers[index];
                          return ListTile(
                            title: Text(customer['fullName'] ?? ''),
                            subtitle: Text(customer['phone'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteCustomer(customer['id']),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'العنوان'),
                maxLines: 2,
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
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await widget.apiService.post(ApiConstants.customers, {
                    'fullName': fullNameController.text,
                    'phone': phoneController.text,
                    'address': addressController.text,
                  });
                  Navigator.pop(context);
                  _loadCustomers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة العميل بنجاح')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $e')),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(String? id) async {
    if (id == null) return;
    try {
      await widget.apiService.delete(ApiConstants.customer(id));
      _loadCustomers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف العميل بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }
}

class ServicesScreen extends StatefulWidget {
  final ApiService apiService;

  const ServicesScreen({super.key, required this.apiService});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<dynamic> _services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.services);
      setState(() {
        // Backend returns array directly, not wrapped in {data: [...]}
        _services = response is List ? response : (response['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل الخدمات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إدارة الخدمات',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddServiceDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة خدمة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _services.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.build, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('لا توجد خدمات حالياً'),
                            SizedBox(height: 8),
                            Text('اضغط على "إضافة خدمة" لإنشاء خدمة جديدة'),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return ListTile(
                            title: Text(service['name'] ?? ''),
                            subtitle: Text('${service['priceSYP'] ?? ''} ل.س'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteService(service['id']),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الخدمة'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 2,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر (ل.س)'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'المدة المقدرة (دقائق)'),
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
                  Navigator.pop(context);
                  _loadServices();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة الخدمة بنجاح')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $e')),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(String? id) async {
    if (id == null) return;
    try {
      await widget.apiService.delete(ApiConstants.service(id));
      _loadServices();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الخدمة بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }
}

class EmployeesScreen extends StatefulWidget {
  final ApiService apiService;

  const EmployeesScreen({super.key, required this.apiService});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<dynamic> _employees = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.employees);
      setState(() {
        // Backend returns array directly, not wrapped in {data: [...]}
        _employees = response is List ? response : (response['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل الموظفين: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إدارة الموظفين',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEmployeeDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة موظف'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _employees.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('لا يوجد موظفين حالياً'),
                            SizedBox(height: 8),
                            Text('اضغط على "إضافة موظف" لإنشاء موظف جديد'),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _employees.length,
                        itemBuilder: (context, index) {
                          final employee = _employees[index];
                          return ListTile(
                            title: Text(employee['fullName'] ?? ''),
                            subtitle: Text('${employee['role'] ?? ''}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteEmployee(employee['id']),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'الدور'),
                items: const [
                  DropdownMenuItem(value: 'OWNER', child: Text('المالك')),
                  DropdownMenuItem(value: 'MANAGER', child: Text('المدير')),
                  DropdownMenuItem(value: 'RECEPTIONIST', child: Text('المستقبل')),
                  DropdownMenuItem(value: 'MECHANIC', child: Text('الميكانيكي')),
                ],
                onChanged: (value) {
                  selectedRole = value ?? 'MECHANIC';
                },
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
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await widget.apiService.post(ApiConstants.register, {
                    'fullName': fullNameController.text,
                    'username': usernameController.text,
                    'password': passwordController.text,
                    'role': selectedRole,
                  });
                  Navigator.pop(context);
                  _loadEmployees();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة الموظف بنجاح')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $e')),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(String? id) async {
    if (id == null) return;
    try {
      await widget.apiService.delete(ApiConstants.employee(id));
      _loadEmployees();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الموظف بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'التقارير والإحصائيات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('عرض التقارير والتحليلات'),
        ],
      ),
    );
  }
}
