import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mechanic_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking.dart';
import '../../services/company_settings_service.dart';
import '../../services/websocket_service.dart';
import '../vehicle_detail/vehicle_detail_screen.dart';

class AvailableBookingsScreen extends StatefulWidget {
  const AvailableBookingsScreen({super.key});

  @override
  State<AvailableBookingsScreen> createState() => _AvailableBookingsScreenState();
}

class _AvailableBookingsScreenState extends State<AvailableBookingsScreen> {
  Timer? _refreshTimer;
  final CompanySettingsService _companySettingsService = CompanySettingsService();
  final WebSocketService _webSocketService = WebSocketService();
  String _companyName = 'تطبيق الميكانيكي';
  String? _companyLogoUrl;

  @override
  void initState() {
    super.initState();
    _loadCompanySettings();
    Future.microtask(() {
      context.read<MechanicProvider>().fetchAvailableBookings();
    });
    _startAutoRefresh();
    
    // Connect to WebSocket
    final authProvider = context.read<AuthProvider>();
    _webSocketService.connect(
      userId: authProvider.userId,
      role: authProvider.currentUser?.role,
    );
    
    // Listen for booking updates
    _webSocketService.addListener(_onBookingUpdate);
  }

  void _onBookingUpdate() {
    final update = _webSocketService.lastBookingUpdate;
    if (update != null) {
      // Reload available bookings when a booking is updated
      context.read<MechanicProvider>().fetchAvailableBookings();
    }
  }

  Future<void> _loadCompanySettings() async {
    try {
      final settings = await _companySettingsService.getCompanySettings();
      if (mounted) {
        setState(() {
          _companyName = settings.companyName;
          _companyLogoUrl = settings.companyLogoUrl;
        });
      }
    } catch (e) {
      // Keep default values on error
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _webSocketService.removeListener(_onBookingUpdate);
    _webSocketService.disconnect();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        context.read<MechanicProvider>().fetchAvailableBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_companyLogoUrl != null && _companyLogoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Image.network(
                  _companyLogoUrl!,
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            Text(_companyName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.pushNamed(context, '/my-assignments');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Consumer<MechanicProvider>(
        builder: (context, mechanicProvider, child) {
          if (mechanicProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mechanicProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(mechanicProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      mechanicProvider.fetchAvailableBookings();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (mechanicProvider.availableBookings.isEmpty) {
            return const Center(
              child: Text('لا توجد سيارات متاحة حالياً'),
            );
          }

          return ListView.builder(
            itemCount: mechanicProvider.availableBookings.length,
            itemBuilder: (context, index) {
              final booking = mechanicProvider.availableBookings[index];
              return _buildBookingCard(booking, mechanicProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, MechanicProvider mechanicProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailScreen(booking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        booking.vehicle?.displayName[0] ?? '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.vehicle?.displayName ?? 'غير معروف',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        if (booking.vehicle?.licensePlate != null)
                          Text(
                            'رقم اللوحة: ${booking.vehicle!.licensePlate}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (booking.customer?.fullName != null)
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'العميل: ${booking.customer!.fullName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الملاحظات: ${booking.notes}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('تأكيد استلام السيارة'),
                        content: Text('هل تريد استلام سيارة ${booking.vehicle?.displayName}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('تأكيد'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      await mechanicProvider.assignBooking(booking.id);
                    }
                  },
                  icon: const Icon(Icons.directions_car),
                  label: const Text('استلام السيارة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
