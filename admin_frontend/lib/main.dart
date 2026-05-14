import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/animated_sidebar.dart';
import 'core/websocket_service.dart';
import 'screens/overview_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/services_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/vehicles_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/company_settings_screen.dart';
import 'screens/quick_booking_screen.dart';
import 'screens/inventory_screen.dart';

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final localeCode = prefs.getString('locale') ?? 'ar';
  
  runApp(MyApp(
    initialThemeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    initialLocale: Locale(localeCode),
  ));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final Locale initialLocale;
  
  const MyApp({super.key, required this.initialThemeMode, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _locale = widget.initialLocale;
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newThemeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setState(() {
      _themeMode = newThemeMode;
    });
    await prefs.setBool('isDarkMode', newThemeMode == ThemeMode.dark);
  }

  void _toggleLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final newLocale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    setState(() {
      _locale = newLocale;
    });
    await prefs.setString('locale', newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Garage System',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      locale: _locale,
      builder: (context, child) {
        final isRTL = _locale.languageCode == 'ar';
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: LoginScreen(onThemeToggle: _toggleTheme, themeMode: _themeMode),
    );
  }
}
class LoginScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final ThemeMode themeMode;
  
  const LoginScreen({super.key, this.onThemeToggle, required this.themeMode});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _rememberMe = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe) {
      final username = prefs.getString('saved_username');
      final password = prefs.getString('saved_password');
      if (username != null && password != null) {
        setState(() {
          _usernameController.text = username;
          _passwordController.text = password;
          _rememberMe = true;
        });
      }
    }
  }

  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_username', username);
      await prefs.setString('saved_password', password);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _controller.dispose();
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
          await _saveCredentials(_usernameController.text, _passwordController.text);
          final apiService = ApiService();
          apiService.setToken(_authService.token);
          apiService.setRefreshToken(_authService.refreshToken);
          
          // Connect to WebSocket
          webSocketService.connect();
          
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(
                apiService: apiService,
                onThemeToggle: widget.onThemeToggle,
                themeMode: widget.themeMode,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 500),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Garage Go',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لوحة التحكم',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 48),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم المستخدم',
                              prefixIcon: Icon(Icons.person_rounded),
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: Icon(Icons.lock_rounded),
                            ),
                            obscureText: true,
                            validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                              const Text('تذكرني'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const SizedBox(
                                  height: 50,
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _handleLogin,
                                    child: const Text('تسجيل الدخول'),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback? onThemeToggle;
  final ThemeMode themeMode;
  
  const DashboardScreen({super.key, required this.apiService, this.onThemeToggle, required this.themeMode});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late ApiService _apiService;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _destinations = [
    const _NavItem(icon: Icons.dashboard_rounded, label: 'نظرة عامة'),
    const _NavItem(icon: Icons.calendar_today_rounded, label: 'الحجوزات'),
    const _NavItem(icon: Icons.flash_on_rounded, label: 'حجز سريع'),
    const _NavItem(icon: Icons.people_rounded, label: 'العملاء'),
    const _NavItem(icon: Icons.directions_car_rounded, label: 'السيارات'),
    const _NavItem(icon: Icons.build_rounded, label: 'الخدمات'),
    const _NavItem(icon: Icons.work_rounded, label: 'الموظفين'),
    const _NavItem(icon: Icons.bar_chart_rounded, label: 'التقارير'),
    const _NavItem(icon: Icons.inventory_2_rounded, label: 'المخزون'),
    const _NavItem(icon: Icons.settings_rounded, label: 'إعدادات النظام'),
    const _NavItem(icon: Icons.lock_rounded, label: 'كلمة المرور'),
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService;
    
    // Listen for low stock alerts
    webSocketService.addListener(_handleLowStockAlert);
  }

  void _handleLowStockAlert(Map<String, dynamic> alert) {
    if (alert['type'] == 'LOW_STOCK' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(alert['message'] ?? 'تنبيه: مخزون منخفض'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'عرض',
            textColor: Colors.white,
            onPressed: () {
              setState(() => _selectedIndex = 8); // Inventory screen index
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    webSocketService.removeListener(_handleLowStockAlert);
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index == -1) {
      // Disconnect WebSocket before logout
      webSocketService.disconnect();
      
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(onThemeToggle: widget.onThemeToggle, themeMode: widget.themeMode),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
      return;
    }
    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1200;
    final isTablet = MediaQuery.sizeOf(context).width >= 800 && MediaQuery.sizeOf(context).width < 1200;

    final screens = [
      OverviewScreen(apiService: _apiService),
      BookingsScreen(apiService: _apiService),
      QuickBookingScreen(apiService: _apiService),
      CustomersScreen(apiService: _apiService),
      VehiclesScreen(apiService: _apiService),
      ServicesScreen(apiService: _apiService),
      EmployeesScreen(apiService: _apiService),
      ReportsScreen(apiService: _apiService),
      InventoryScreen(apiService: _apiService),
      CompanySettingsScreen(apiService: _apiService),
      ChangePasswordScreen(apiService: _apiService),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: !isDesktop ? _buildDrawer() : null,
      appBar: !isDesktop
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E293B),
              title: Text(_destinations[_selectedIndex].label),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  onPressed: () => _onDestinationSelected(-1),
                  tooltip: 'تسجيل الخروج',
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            AnimatedSidebar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              isExpanded: true,
              onThemeToggle: widget.onThemeToggle,
              themeMode: widget.themeMode,
            ),
          if (isTablet)
            AnimatedSidebar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              isExpanded: false,
              onThemeToggle: widget.onThemeToggle,
              themeMode: widget.themeMode,
            ),
          if (isDesktop || isTablet) const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    ...previousChildren,
                    ?currentChild,
                  ],
                );
              },
              child: Container(
                key: ValueKey<int>(_selectedIndex),
                child: _selectedIndex < screens.length
                    ? screens[_selectedIndex]
                    : const Center(child: Text('صفحة غير موجودة')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      elevation: 0,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_car, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Garage Go',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        'لوحة التحكم',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: _destinations.length,
                itemBuilder: (context, index) {
                  final item = _destinations[index];
                  final isSelected = _selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: Icon(
                        item.icon,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade600,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isSelected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                          : null,
                      onTap: () => _onDestinationSelected(index),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => _onDestinationSelected(-1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
