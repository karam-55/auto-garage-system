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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: Using Render backend API
  print('Using Render backend: ${BackendConstants.backendUrl}');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        title: 'تطبيق الميكانيكي',
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
        onGenerateTitle: (context) async {
          // Load company settings to use as app title
          try {
            final response = await Future.delayed(
              const Duration(milliseconds: 100),
              () => 'تطبيق الميكانيكي', // Default title
            );
            return response;
          } catch (e) {
            return 'تطبيق الميكانيكي';
          }
        },
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
