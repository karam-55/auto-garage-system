import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import './core/constants/backend_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/mechanic_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/available_bookings/available_bookings_screen.dart';
import 'screens/my_assignments/my_assignments_screen.dart';
import 'services/company_settings_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: Using Render backend API
  print('Using Render backend: ${BackendConstants.backendUrl}');
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CompanySettingsService _companySettingsService = CompanySettingsService();
  String _appTitle = 'تطبيق الميكانيكي';

  @override
  void initState() {
    super.initState();
    _loadCompanySettings();
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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', ''),
        ],
        locale: const Locale('ar', ''),
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/available-bookings': (context) => const AvailableBookingsScreen(),
          '/my-assignments': (context) => const MyAssignmentsScreen(),
        },
      ),
    );
  }
}
