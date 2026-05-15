import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mechanic_app_new/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './core/constants/backend_constants.dart';
import './core/logger.dart';
import 'providers/auth_provider.dart';
import 'providers/mechanic_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/available_bookings/available_bookings_screen.dart';
import 'screens/my_assignments/my_assignments_screen.dart';
import 'services/company_settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('locale') ?? 'ar';

  // Note: Using Render backend API
  logger.info('Using Render backend: ${BackendConstants.backendUrl}');

  runApp(MyApp(initialLocale: Locale(localeCode)));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  
  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CompanySettingsService _companySettingsService = CompanySettingsService();
  String _appTitle = 'تطبيق الميكانيكي';
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _loadCompanySettings();
  }

  void _toggleLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final newLocale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    setState(() {
      _locale = newLocale;
    });
    await prefs.setString('locale', newLocale.languageCode);
  }

  Future<void> _loadCompanySettings() async {
    try {
      final settings = await _companySettingsService.getCompanySettings();
      if (mounted) {
        setState(() {
          _appTitle = settings.companyName;
        });
      }
    } catch (e) {
      // Keep default title on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MechanicProvider>(
          create: (context) => MechanicProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? MechanicProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: _appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Cairo',
          textTheme: GoogleFonts.cairoTextTheme(),
        ),
        localizationsDelegates: [
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
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/available-bookings': (context) => const AvailableBookingsScreen(),
          '/my-assignments': (context) => const MyAssignmentsScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.tryAutoLogin();

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/available-bookings');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
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
              Icons.build,
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
