import 'package:flutter/material.dart';
import 'dart:async';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../core/widgets/professional_dialog.dart';
import '../core/widgets/loading_screen.dart';

class VehiclesScreen extends StatefulWidget {
  final ApiService apiService;

  const VehiclesScreen({super.key, required this.apiService});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<dynamic> _vehicles = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _totalCount = 0;
  int _totalPages = 0;
  bool _hasNextPage = false;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (_hasNextPage && !_isLoadingMore && !_isLoading) {
        _loadMoreVehicles();
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text.trim();
        _currentPage = 1;
        _vehicles = [];
      });
      _loadVehicles();
    });
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      String url = '${ApiConstants.vehicles}?page=$_currentPage&limit=$_pageSize';
      if (_searchQuery.isNotEmpty) {
        url += '&search=$_searchQuery';
      }
      final response = await widget.apiService.get(url);
      setState(() {
        final raw = response is List ? response : (response['data'] ?? []);
        _vehicles = List<Map<String, dynamic>>.from(raw);
        _totalCount = response['totalCount'] ?? 0;
        _totalPages = response['totalPages'] ?? 0;
        _hasNextPage = response['hasNextPage'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل السيارات: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreVehicles() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      _currentPage++;
      String url = '${ApiConstants.vehicles}?page=$_currentPage&limit=$_pageSize';
      if (_searchQuery.isNotEmpty) {
        url += '&search=$_searchQuery';
      }
      final response = await widget.apiService.get(url);
      setState(() {
        final raw = response is List ? response : (response['data'] ?? []);
        _vehicles.addAll(List<Map<String, dynamic>>.from(raw));
        _totalCount = response['totalCount'] ?? 0;
        _totalPages = response['totalPages'] ?? 0;
        _hasNextPage = response['hasNextPage'] ?? false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل المزيد: $e')),
        );
      }
    }
  }

  List<dynamic> get _filteredVehicles {
    return _vehicles;
  }

  Future<void> _updateVehicle(String vehicleId, String licensePlate) async {
    try {
      await widget.apiService.put(ApiConstants.vehicle(vehicleId), {'licensePlate': licensePlate});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث رقم اللوحة بنجاح')),
        );
        _loadVehicles();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحديث رقم اللوحة: $e')),
        );
      }
    }
  }

  void _showEditDialog(Map<String, dynamic> vehicle) {
    final controller = TextEditingController(text: vehicle['licensePlate'] ?? '');
    showProfessionalDialog(
      context: context,
      title: 'تعديل رقم اللوحة',
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'رقم اللوحة',
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      onConfirm: () {
        _updateVehicle(vehicle['id'], controller.text);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionLoading(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _vehicles.isEmpty
                      ? _buildEmptyState()
                      : _buildVehiclesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 600;

    return isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إدارة السيارات',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '$_totalCount سيارة',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              _buildSearchField(),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة السيارات',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '$_totalCount سيارة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 300, child: _buildSearchField()),
            ],
          );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'بحث عن سيارة...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا توجد سيارات', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVehiclesList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
                ? 2
                : 1;

        return GridView.builder(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _filteredVehicles.length + (_hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _filteredVehicles.length && _hasNextPage) {
              return const Center(child: CircularProgressIndicator());
            }
            final vehicle = _filteredVehicles[index];
            return _VehicleCard(
              vehicle: vehicle,
              onEdit: () => _showEditDialog(vehicle),
            );
          },
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onEdit;

  const _VehicleCard({required this.vehicle, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_rounded, color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: onEdit,
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          _buildInfoRow('السنة', '${vehicle['year'] ?? '-'}'),
          const SizedBox(height: 8),
          _buildInfoRow('رقم اللوحة', vehicle['licensePlate'] ?? 'غير متوفر'),
          const SizedBox(height: 8),
          _buildInfoRow('معرف التتبع', vehicle['publicCarId'] ?? 'غير متوفر'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
