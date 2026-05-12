import 'package:flutter/material.dart';
import '../core/widgets/animated_card.dart';
import '../core/widgets/loading_screen.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class VehiclesScreen extends StatefulWidget {
  final ApiService apiService;

  const VehiclesScreen({super.key, required this.apiService});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<dynamic> _vehicles = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.vehicles);
      setState(() {
        final raw = response is List ? response : (response['data'] ?? []);
        _vehicles = List<Map<String, dynamic>>.from(raw);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل السيارات: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredVehicles {
    if (_searchQuery.isEmpty) return _vehicles;
    return _vehicles.where((vehicle) {
      final make = vehicle['make']?.toString().toLowerCase() ?? '';
      final model = vehicle['model']?.toString().toLowerCase() ?? '';
      final plate = vehicle['licensePlate']?.toString().toLowerCase() ?? '';
      return make.contains(_searchQuery.toLowerCase()) ||
          model.contains(_searchQuery.toLowerCase()) ||
          plate.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _updateVehicle(String vehicleId, String licensePlate) async {
    try {
      await widget.apiService.put(
        ApiConstants.vehicle(vehicleId),
        {
          'licensePlate': licensePlate,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث رقم اللوحة بنجاح'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadVehicles();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث رقم اللوحة: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditDialog(Map<String, dynamic> vehicle) {
    final controller = TextEditingController(text: vehicle['licensePlate'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل رقم اللوحة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'رقم اللوحة',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateVehicle(vehicle['id'], controller.text);
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionLoading(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _vehicles.isEmpty
                    ? _buildEmptyState()
                    : _buildVehiclesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'السيارات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'بحث عن سيارة...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد سيارات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              '${vehicle['make']} ${vehicle['model']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('السنة: ${vehicle['year']}'),
                Text('رقم اللوحة: ${vehicle['licensePlate'] ?? 'غير متوفر'}'),
                Text('Public ID: ${vehicle['publicCarId'] ?? 'غير متوفر'}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(vehicle),
            ),
          ),
        );
      },
    );
  }
}
