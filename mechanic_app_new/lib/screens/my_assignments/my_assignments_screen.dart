import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mechanic_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/mechanic_assignment.dart';
import '../vehicle_detail/vehicle_detail_screen.dart';
import '../update_maintenance_status/update_maintenance_status_screen.dart';

class MyAssignmentsScreen extends StatefulWidget {
  const MyAssignmentsScreen({super.key});

  @override
  State<MyAssignmentsScreen> createState() => _MyAssignmentsScreenState();
}

class _MyAssignmentsScreenState extends State<MyAssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MechanicProvider>().fetchMyAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مهامي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/available-bookings');
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
                      mechanicProvider.fetchMyAssignments();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (mechanicProvider.myAssignments.isEmpty) {
            return const Center(
              child: Text('لا توجد مهام حالياً'),
            );
          }

          return ListView.builder(
            itemCount: mechanicProvider.myAssignments.length,
            itemBuilder: (context, index) {
              final assignment = mechanicProvider.myAssignments[index];
              return _buildAssignmentCard(assignment);
            },
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(MechanicAssignment assignment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(assignment.booking?.vehicle?.displayName[0] ?? '?'),
        ),
        title: Text(assignment.booking?.vehicle?.displayName ?? 'غير معروف'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (assignment.booking?.vehicle?.licensePlate != null)
              Text('رقم اللوحة: ${assignment.booking!.vehicle!.licensePlate}'),
            if (assignment.booking?.customer?.fullName != null)
              Text('العميل: ${assignment.booking!.customer!.fullName}'),
            Text('الحالة: ${_getStatusText(assignment.status)}'),
            if (assignment.notes != null && assignment.notes!.isNotEmpty)
              Text('الملاحظات: ${assignment.notes}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateMaintenanceStatusScreen(assignment: assignment),
              ),
            );
          },
        ),
        onTap: () {
          if (assignment.booking != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VehicleDetailScreen(booking: assignment.booking!),
              ),
            );
          }
        },
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ASSIGNED':
        return 'موكلة';
      case 'IN_PROGRESS':
        return 'قيد العمل';
      case 'COMPLETED':
        return 'مكتملة';
      case 'CANCELLED':
        return 'ملغية';
      default:
        return status;
    }
  }
}
