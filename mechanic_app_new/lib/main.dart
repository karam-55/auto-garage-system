import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mechanic_app_new/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import './core/constants/backend_constants.dart';
import './core/logger.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/booking_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/available_bookings/available_bookings_screen.dart';
import 'screens/my_assignments/my_assignments_screen.dart';
import 'services/company_settings_service.dart';

void main() async {
  // إضافة Error Handling شامل قبل تهيئة Flutter bindings
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.severe('Flutter Error: ${details.exception}');
    logger.severe('Stack Trace: ${details.stack}');
    FlutterError.presentError(details);
  };

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('locale') ?? 'ar';

    // Note: Using Render backend API
    logger.info('Using Render backend: ${BackendConstants.backendUrl}');
    logger.info('Locale: $localeCode');

    runApp(ProviderScope(child: MyApp(initialLocale: Locale(localeCode))));
  }, (error, stack) {
    logger.severe('Uncaught Error: $error');
    logger.severe('Stack Trace: $stack');
  });
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
    return MaterialApp(
      title: _appTitle,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return ErrorScreen(
            error: details.exception.toString(),
            stackTrace: details.stack.toString(),
          );
        };
        
        final isRTL = _locale.languageCode == 'ar';
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
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
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/available-bookings': (context) => const AvailableBookingsScreen(),
        '/my-assignments': (context) => const MyAssignmentsScreen(),
      },
    );
  }
}

// ErrorWidget مخصص لعرض الأخطاء بدلاً من الشاشة البيضاء
class ErrorScreen extends StatelessWidget {
  final String? error;
  final String? stackTrace;

  const ErrorScreen({super.key, this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'حدث خطأ غير متوقع',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (error != null)
                Text(
                  'الخطأ: $error',
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('العودة إلى تسجيل الدخول'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text('إعادة تشغيل التطبيق'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      logger.info('Checking auth status...');
      
      // تحقق من حالة المصادقة
      await ref.read(authStateProvider.notifier).checkAuthStatus();
      
      if (!mounted) return;
      
      final authState = ref.read(authStateProvider);
      
      if (authState.isAuthenticated) {
        logger.info('User is authenticated, navigating to available bookings');
        Navigator.pushReplacementNamed(context, '/available-bookings');
      } else {
        logger.info('User is not authenticated, navigating to login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e, stack) {
      logger.severe('Error in splash screen: $e');
      logger.severe('Stack trace: $stack');
      
      if (mounted) {
        // في حالة الخطأ، اذهب إلى شاشة تسجيل الدخول
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
            SizedBox(height: 16),
            Text(
              'جاري التحميل...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
