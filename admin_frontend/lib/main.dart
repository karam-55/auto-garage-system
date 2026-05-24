import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Conditional import for flutter_secure_storage (only on mobile)
import 'package:flutter_secure_storage/flutter_secure_storage.dart' if (dart.library.io) 'package:flutter_secure_storage/flutter_secure_storage_stub.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/animated_sidebar.dart';
import 'core/websocket_service.dart';
import 'screens/overview_screen.dart';
import 'screens/dashboard_screen.dart';
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
// Accounting Screens
import 'screens/accounting/chart_of_accounts_screen.dart';
import 'screens/accounting/journal_entries_screen.dart';
import 'screens/accounting/accounting_screen.dart';
import 'screens/accounting/trial_balance_screen.dart';
import 'screens/accounting/profit_loss_screen.dart';
import 'screens/accounting/balance_sheet_screen.dart';
import 'screens/accounting/general_ledger_screen.dart';
import 'screens/accounting/cash_flow_screen.dart';
import 'screens/accounting/break_even_screen.dart';
import 'screens/accounting/trading_account_screen.dart';
import 'screens/accounting/payroll_settings_screen.dart';
import 'screens/accounting/payroll_screen.dart';
import 'screens/accounting/payroll_report_screen.dart';
import 'screens/accounting/vendors_screen.dart';
import 'screens/accounting/purchase_invoices_screen.dart';
import 'screens/accounting/expenses_screen.dart';
import 'screens/accounting/bank_accounts_screen.dart';
// ERP Screens
import 'screens/purchasing/purchase_orders_screen.dart';
import 'screens/sales/quotations_screen.dart';
import 'screens/sales/sales_orders_screen.dart';
import 'screens/warehouse/warehouses_screen.dart';
import 'screens/warehouse/inventory_transfers_screen.dart';
import 'screens/manufacturing/boms_screen.dart';
import 'screens/manufacturing/manufacturing_orders_screen.dart';
import 'screens/crm/leads_screen.dart';
import 'screens/hr/employee_contracts_screen.dart';
import 'screens/hr/leave_requests_screen.dart';
import 'screens/fixed_assets/fixed_assets_screen.dart';
import 'screens/maintenance/maintenance_contracts_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/auth_provider.dart';

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  // Force Arabic locale to ensure RTL
  final locale = const Locale('ar');
  
  runApp(MyApp(
    initialThemeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    initialLocale: locale,
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
    return ProviderScope(
      child: MaterialApp(
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
            child: child ?? const SizedBox(),
          );
        },
        home: SplashScreen(onThemeToggle: _toggleTheme, themeMode: _themeMode),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final ThemeMode themeMode;

  const SplashScreen({super.key, this.onThemeToggle, required this.themeMode});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Try auto login using refresh token
    final isLoggedIn = await _authService.tryAutoLogin();

    if (mounted) {
      if (isLoggedIn) {
        // User is logged in, navigate to dashboard
        final apiService = ApiService();
        apiService.setToken(_authService.token);
        apiService.setRefreshToken(_authService.refreshToken);
        
        // WebSocket disabled - backend does not support WebSocket
        // webSocketService.connect();
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GarageDashboardScreen(
              apiService: apiService,
              onThemeToggle: widget.onThemeToggle,
              themeMode: widget.themeMode,
            ),
          ),
        );
      } else {
        // User is not logged in, navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              onThemeToggle: widget.onThemeToggle,
              themeMode: widget.themeMode,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 80,
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
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
    if (kIsWeb) {
      // Use SharedPreferences on web
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
    } else {
      // Use FlutterSecureStorage on mobile
      final _storage = FlutterSecureStorage();
      final rememberMe = await _storage.read(key: 'remember_me') == 'true';
      if (rememberMe) {
        final username = await _storage.read(key: 'saved_username');
        final password = await _storage.read(key: 'saved_password');
        if (username != null && password != null) {
          setState(() {
            _usernameController.text = username;
            _passwordController.text = password;
            _rememberMe = true;
          });
        }
      }
    }
  }

  Future<void> _saveCredentials(String username, String password) async {
    if (kIsWeb) {
      // Use SharedPreferences on web
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
    } else {
      // Use FlutterSecureStorage on mobile
      final _storage = FlutterSecureStorage();
      if (_rememberMe) {
        await _storage.write(key: 'remember_me', value: 'true');
        await _storage.write(key: 'saved_username', value: username);
        await _storage.write(key: 'saved_password', value: password);
      } else {
        await _storage.write(key: 'remember_me', value: 'false');
        await _storage.delete(key: 'saved_username');
        await _storage.delete(key: 'saved_password');
      }
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
        final loginData = await _authService.login(
          _usernameController.text,
          _passwordController.text,
        );
        
        if (mounted) {
          await _saveCredentials(_usernameController.text, _passwordController.text);
          
          // Save user data to SharedPreferences for authProvider
          if (loginData['user'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user', jsonEncode(loginData['user']));
          }
          
          final apiService = ApiService();
          apiService.setToken(_authService.token);
          apiService.setRefreshToken(_authService.refreshToken);
          
          // WebSocket disabled - backend does not support WebSocket
          // webSocketService.connect();
          
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => GarageDashboardScreen(
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

class GarageDashboardScreen extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback? onThemeToggle;
  final ThemeMode themeMode;
  
  const GarageDashboardScreen({super.key, required this.apiService, this.onThemeToggle, required this.themeMode});

  @override
  State<GarageDashboardScreen> createState() => _GarageDashboardScreenState();
}

class _GarageDashboardScreenState extends State<GarageDashboardScreen> {
  int _selectedIndex = 0;
  late ApiService _apiService;
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _destinations = [
    const _NavItem(icon: Icons.dashboard_rounded, label: 'لوحة القيادة'),
    const _NavItem(icon: Icons.dashboard_rounded, label: 'نظرة عامة'),
    const _NavItem(icon: Icons.calendar_today_rounded, label: 'الحجوزات'),
    const _NavItem(icon: Icons.flash_on_rounded, label: 'حجز لعميل مسجل مسبقا'),
    const _NavItem(icon: Icons.people_rounded, label: 'العملاء'),
    const _NavItem(icon: Icons.directions_car_rounded, label: 'السيارات'),
    const _NavItem(icon: Icons.build_rounded, label: 'الخدمات'),
    const _NavItem(icon: Icons.work_rounded, label: 'الموظفين'),
    const _NavItem(icon: Icons.bar_chart_rounded, label: 'التقارير'),
    const _NavItem(icon: Icons.inventory_2_rounded, label: 'المخزون'),
    const _NavItem(icon: Icons.account_balance_rounded, label: 'دليل الحسابات'),
    const _NavItem(icon: Icons.receipt_long_rounded, label: 'القيود اليومية'),
    const _NavItem(icon: Icons.balance_rounded, label: 'ميزان المراجعة'),
    const _NavItem(icon: Icons.trending_up_rounded, label: 'قائمة الدخل'),
    const _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'الميزانية العمومية'),
    const _NavItem(icon: Icons.menu_book_rounded, label: 'دفتر الأستاذ العام'),
    const _NavItem(icon: Icons.account_balance_rounded, label: 'التدفقات النقدية'),
    const _NavItem(icon: Icons.show_chart_rounded, label: 'نقطة التعادل'),
    const _NavItem(icon: Icons.trending_up_rounded, label: 'تقرير المتجارة'),
    const _NavItem(icon: Icons.settings_rounded, label: 'إعدادات الرواتب'),
    const _NavItem(icon: Icons.receipt_long_rounded, label: 'كشوف الرواتب'),
    const _NavItem(icon: Icons.description_rounded, label: 'تقرير الرواتب'),
    const _NavItem(icon: Icons.people_rounded, label: 'الموردين'),
    const _NavItem(icon: Icons.receipt_long_rounded, label: 'فواتير الشراء'),
    const _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'المصاريف'),
    const _NavItem(icon: Icons.account_balance_rounded, label: 'الحسابات البنكية'),
    const _NavItem(icon: Icons.settings_rounded, label: 'إعدادات النظام'),
    const _NavItem(icon: Icons.lock_rounded, label: 'كلمة المرور'),
    // ERP Screens
    const _NavItem(icon: Icons.shopping_cart_rounded, label: 'أوامر الشراء'),
    const _NavItem(icon: Icons.description_rounded, label: 'عروض الأسعار'),
    const _NavItem(icon: Icons.receipt_long_rounded, label: 'أوامر البيع'),
    const _NavItem(icon: Icons.warehouse_rounded, label: 'المستودعات'),
    const _NavItem(icon: Icons.swap_horiz_rounded, label: 'نقل المخزون'),
    const _NavItem(icon: Icons.list_alt_rounded, label: 'قوائم المواد'),
    const _NavItem(icon: Icons.build_circle_rounded, label: 'أوامر الإنتاج'),
    const _NavItem(icon: Icons.people_outline_rounded, label: 'العملاء المحتملين'),
    const _NavItem(icon: Icons.description_rounded, label: 'عقود الموظفين'),
    const _NavItem(icon: Icons.event_busy_rounded, label: 'طلبات الإجازة'),
    const _NavItem(icon: Icons.account_balance_rounded, label: 'الأصول الثابتة'),
    const _NavItem(icon: Icons.build_rounded, label: 'عقود الصيانة'),
  ];


  @override
  void initState() {
    super.initState();
    print('GarageDashboardScreen: initState called');
    print('GarageDashboardScreen: widget.apiService is null: ${widget.apiService == null}');
    if (widget.apiService == null) {
      print('GarageDashboardScreen: ERROR - apiService is null!');
    }
    _apiService = widget.apiService;
    
    // WebSocket disabled - backend does not support WebSocket
    // webSocketService.addListener(_handleLowStockAlert);
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
    // WebSocket disabled - backend does not support WebSocket
    // webSocketService.removeListener(_handleLowStockAlert);
    super.dispose();
  }

  void _onDestinationSelected(int index) async {
    if (index == -1) {
      // WebSocket disabled - backend does not support WebSocket
      // webSocketService.disconnect();
      
      // Clear user data from auth provider
      ProviderScope.containerOf(context).read(authProvider.notifier).clearUser();
      
      // Clear tokens from AuthService
      await _authService.logout();
      
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onLocaleToggle() async {
    final prefs = await SharedPreferences.getInstance();
    final currentLocale = prefs.getString('locale') ?? 'ar';
    final newLocale = currentLocale == 'ar' ? 'en' : 'ar';
    await prefs.setString('locale', newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1200;
    final isTablet = MediaQuery.sizeOf(context).width >= 800 && MediaQuery.sizeOf(context).width < 1200;

    final screens = [
      const DashboardScreen(),
      OverviewScreen(apiService: _apiService),
      BookingsScreen(apiService: _apiService),
      QuickBookingScreen(apiService: _apiService),
      CustomersScreen(apiService: _apiService),
      VehiclesScreen(apiService: _apiService),
      ServicesScreen(apiService: _apiService),
      EmployeesScreen(apiService: _apiService),
      ReportsScreen(apiService: _apiService),
      InventoryScreen(apiService: _apiService),
      ChartOfAccountsScreen(apiService: _apiService),
      JournalEntriesScreen(apiService: _apiService),
      const TrialBalanceScreen(), // Index 12 - ميزان المراجعة
      const ProfitLossScreen(), // Index 13 - قائمة الدخل
      const BalanceSheetScreen(), // Index 14 - الميزانية العمومية
      const GeneralLedgerScreen(), // Index 15 - دفتر الأستاذ العام
      const CashFlowScreen(), // Index 16 - التدفقات النقدية
      const BreakEvenScreen(), // Index 17 - نقطة التعادل
      const TradingAccountScreen(), // Index 18 - تقرير المتجارة
      PayrollSettingsScreen(apiService: _apiService), // Index 19 - إعدادات الرواتب
      PayrollScreen(apiService: _apiService), // Index 20 - كشوف الرواتب
      PayrollReportScreen(apiService: _apiService), // Index 21 - تقرير الرواتب
      VendorsScreen(apiService: _apiService), // Index 22 - الموردين
      PurchaseInvoicesScreen(apiService: _apiService), // Index 23 - فواتير الشراء
      ExpensesScreen(apiService: _apiService), // Index 24 - المصاريف
      BankAccountsScreen(apiService: _apiService), // Index 25 - الحسابات البنكية
      CompanySettingsScreen(apiService: _apiService), // Index 26 - إعدادات النظام
      ChangePasswordScreen(apiService: _apiService), // Index 27 - كلمة المرور
      // ERP Screens
      const PurchaseOrdersScreen(), // Index 28 - أوامر الشراء
      const QuotationsScreen(), // Index 29 - عروض الأسعار
      const SalesOrdersScreen(), // Index 30 - أوامر البيع
      const WarehousesScreen(), // Index 31 - المستودعات
      InventoryTransfersScreen(), // Index 32 - نقل المخزون
      const BomsScreen(), // Index 33 - قوائم المواد
      const ManufacturingOrdersScreen(), // Index 34 - أوامر الإنتاج
      const LeadsScreen(), // Index 35 - العملاء المحتملين
      const EmployeeContractsScreen(), // Index 36 - عقود الموظفين
      const LeaveRequestsScreen(), // Index 37 - طلبات الإجازة
      const FixedAssetsScreen(), // Index 38 - الأصول الثابتة
      const MaintenanceContractsScreen(), // Index 39 - عقود الصيانة
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
                  onPressed: widget.onThemeToggle,
                  icon: Icon(
                    widget.themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  tooltip: 'تبديل السمة',
                ),
                IconButton(
                  onPressed: _onLocaleToggle,
                  icon: const Icon(Icons.language),
                  tooltip: 'تغيير اللغة',
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            AnimatedSidebar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              isExpanded: isDesktop,
              onToggle: () {},
              onThemeToggle: widget.onThemeToggle,
              onLocaleToggle: _onLocaleToggle,
              themeMode: widget.themeMode,
              destinations: _destinations,
            ),
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
                    if (currentChild != null) currentChild,
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
