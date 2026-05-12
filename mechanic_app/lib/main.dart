import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/mechanic_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/available_bookings/available_bookings_screen.dart';
import 'screens/my_assignments/my_assignments_screen.dart';
import 'core/constants/supabase_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );
  
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const MainScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
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
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = await authProvider.checkAuthStatus();
    
    if (mounted) {
      if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 80, color: Colors.orange),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('تطبيق الميكانيكي'),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AvailableBookingsScreen(),
    const MyAssignmentsScreen(),
  ];

  final List<String> _titles = [
    'الحجوزات المتاحة',
    'مهامي',
  ];

  final List<IconData> _icons = [
    Icons.list_alt,
    Icons.assignment,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: List.generate(
          _screens.length,
          (index) => NavigationDestination(
            icon: Icon(_icons[index]),
            label: _titles[index],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton(
                icon: CircleAvatar(
                  child: Text(authProvider.userName?[0] ?? 'M'),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text('تسجيل الخروج (${authProvider.userName})'),
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.logout();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
