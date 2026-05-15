import 'package:flutter/material.dart';
import 'dart:async';
import '../core/widgets/loading_screen.dart';
import '../core/widgets/professional_dialog.dart';
import '../core/services/api_service.dart';
import '../core/services/websocket_service.dart';
import '../core/constants/api_constants.dart';
import 'create_booking_screen.dart';
import 'invoice_screen.dart';

class BookingsScreen extends StatefulWidget {
  final ApiService apiService;

  const BookingsScreen({super.key, required this.apiService});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatus;
  DateTimeRange? _selectedDateRange;
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _totalCount = 0;
  int _totalPages = 0;
  bool _hasNextPage = false;
  static const int _pageSize = 20;
  final WebSocketService _webSocketService = WebSocketService();

  final List<String> _statusOptions = [
    'ALL',
    'PENDING',
    'IN_PROGRESS',
    'WAITING_PARTS',
    'READY',
    'DELIVERED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    
    // Connect to WebSocket
    _webSocketService.connect();
    
    // Listen for booking updates
    _webSocketService.addListener(_onBookingUpdate);
  }

  void _onBookingUpdate() {
    final update = _webSocketService.lastBookingUpdate;
    if (update != null) {
      // Reload bookings when a booking is updated
      _loadBookings();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    _webSocketService.removeListener(_onBookingUpdate);
    _webSocketService.disconnect();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (_hasNextPage && !_isLoadingMore && !_isLoading) {
        _loadMoreBookings();
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text.trim();
        _currentPage = 1;
        _bookings = [];
      });
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      String url = '${ApiConstants.bookings}?page=$_currentPage&limit=$_pageSize';
      
      if (_selectedStatus != null && _selectedStatus != 'ALL') {
        url += '&status=$_selectedStatus';
      }
      
      if (_selectedDateRange != null) {
        url += '&from=${_selectedDateRange!.start.toIso8601String()}';
        url += '&to=${_selectedDateRange!.end.toIso8601String()}';
      }
      
      if (_searchQuery.isNotEmpty) {
        url += '&search=$_searchQuery';
      }
      
      final response = await widget.apiService.get(url);
      setState(() {
        final raw = response is List ? response : (response['data'] ?? []);
        _bookings = List<Map<String, dynamic>>.from(raw);
        _totalCount = response['totalCount'] ?? 0;
        _totalPages = response['totalPages'] ?? 0;
        _hasNextPage = response['hasNextPage'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل الحجوزات: $e')));
      }
    }
  }

  Future<void> _loadMoreBookings() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      _currentPage++;
      String url = '${ApiConstants.bookings}?page=$_currentPage&limit=$_pageSize';
      
      if (_selectedStatus != null && _selectedStatus != 'ALL') {
        url += '&status=$_selectedStatus';
      }
      
      if (_selectedDateRange != null) {
        url += '&from=${_selectedDateRange!.start.toIso8601String()}';
        url += '&to=${_selectedDateRange!.end.toIso8601String()}';
      }
      
      if (_searchQuery.isNotEmpty) {
        url += '&search=$_searchQuery';
      }
      
      final response = await widget.apiService.get(url);
      setState(() {
        final raw = response is List ? response : (response['data'] ?? []);
        _bookings.addAll(List<Map<String, dynamic>>.from(raw));
        _totalCount = response['totalCount'] ?? 0;
        _totalPages = response['totalPages'] ?? 0;
        _hasNextPage = response['hasNextPage'] ?? false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل المزيد: $e')));
      }
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    return _bookings;
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
                  : _bookings.isEmpty
                      ? _buildEmptyState()
                      : _buildBookingsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 800;

    return isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إدارة الحجوزات',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '$_totalCount حجز',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              _buildSearchField(),
              const SizedBox(height: 8),
              _buildStatusFilter(),
              const SizedBox(height: 8),
              _buildDateFilter(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToCreateBooking(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('حجز لعميل جديد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة الحجوزات',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '$_totalCount حجز',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(width: 200, child: _buildSearchField()),
              const SizedBox(width: 8),
              SizedBox(width: 150, child: _buildStatusFilter()),
              const SizedBox(width: 8),
              _buildDateFilterButton(),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _navigateToCreateBooking(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('حجز لعميل جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedStatus,
      decoration: InputDecoration(
        hintText: 'الحالة',
        prefixIcon: const Icon(Icons.filter_list, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(_getStatusText(status)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
          _currentPage = 1;
          _bookings = [];
        });
        _loadBookings();
      },
    );
  }

  Widget _buildDateFilterButton() {
    return OutlinedButton.icon(
      onPressed: _selectDateRange,
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(
        _selectedDateRange != null
            ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}'
            : 'تاريخ',
        style: const TextStyle(fontSize: 13),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildDateFilter() {
    return OutlinedButton.icon(
      onPressed: _selectDateRange,
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(
        _selectedDateRange != null
            ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}'
            : 'تاريخ',
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      locale: const Locale('ar', 'SA'),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDateRange = picked;
        _currentPage = 1;
        _bookings = [];
      });
      _loadBookings();
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ALL':
        return 'الكل';
      case 'PENDING':
        return 'قيد الانتظار';
      case 'IN_PROGRESS':
        return 'جاري العمل';
      case 'WAITING_PARTS':
        return 'بانتظار القطع';
      case 'READY':
        return 'جاهز';
      case 'DELIVERED':
        return 'تم التسليم';
      case 'CANCELLED':
        return 'ملغي';
      default:
        return status;
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'بحث حجز...',
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
          Icon(Icons.calendar_today_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا توجد حجوزات حالياً', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('اضغط على "إضافة حجز جديد" لإنشاء حجز جديد', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateBooking(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('إضافة حجز جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 2
            : 1;

        return GridView.builder(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _filteredBookings.length + (_hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _filteredBookings.length && _hasNextPage) {
              return const Center(child: CircularProgressIndicator());
            }
            return _BookingCard(
              booking: _filteredBookings[index],
              onInvoice: () => _showInvoiceForBooking(_filteredBookings[index]),
              onEdit: () => _showEditBookingDialog(context, _filteredBookings[index]),
              onUpdateStatus: () => _showUpdateStatusDialog(context, _filteredBookings[index]),
              onDelete: () => _deleteBooking(_filteredBookings[index]['id']),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.grey;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'WAITING_PARTS':
        return Colors.orange;
      case 'READY':
        return Colors.green;
      case 'DELIVERED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.pending_rounded;
      case 'IN_PROGRESS':
        return Icons.build_rounded;
      case 'WAITING_PARTS':
        return Icons.inventory_2_rounded;
      case 'READY':
        return Icons.check_circle_rounded;
      case 'DELIVERED':
        return Icons.local_shipping_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    if (date is String) {
      try {
        final dateTime = DateTime.parse(date);
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } catch (e) {
        return date;
      }
    }
    return date.toString();
  }

  void _navigateToCreateBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBookingScreen(
          apiService: widget.apiService,
          onBookingCreated: _loadBookings,
        ),
      ),
    );
  }

  void _showAddBookingDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final customerIdController = TextEditingController();
    final vehicleIdController = TextEditingController();
    final notesController = TextEditingController();

    showProfessionalDialog(
      context: context,
      title: 'إضافة حجز جديد',
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: customerIdController,
                decoration: InputDecoration(
                  labelText: 'معرف العميل',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: vehicleIdController,
                decoration: InputDecoration(
                  labelText: 'معرف المركبة',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      onConfirm: () async {
        if (formKey.currentState?.validate() ?? false) {
          try {
            await widget.apiService.post(ApiConstants.bookings, {
              'customerId': customerIdController.text,
              'vehicleId': vehicleIdController.text,
              'notes': notesController.text,
            });
            if (mounted) {
              Navigator.pop(context);
              _loadBookings();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الحجز بنجاح')));
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
            }
          }
        }
      },
    );
  }

  void _showEditBookingDialog(BuildContext context, Map<String, dynamic> booking) {
    final formKey = GlobalKey<FormState>();
    final notesController = TextEditingController(text: booking['notes']?.toString() ?? '');

    showProfessionalDialog(
      context: context,
      title: 'تعديل الحجز',
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: notesController,
          decoration: InputDecoration(
            labelText: 'ملاحظات',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          maxLines: 3,
        ),
      ),
      onConfirm: () async {
        try {
          await widget.apiService.patch(
            '${ApiConstants.bookings}/${booking['id']}',
            body: {'notes': notesController.text},
          );
          if (mounted) {
            Navigator.pop(context);
            _loadBookings();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الحجز بنجاح')));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
          }
        }
      },
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Map<String, dynamic> booking) {
    final statuses = ['PENDING', 'IN_PROGRESS', 'WAITING_PARTS', 'READY', 'DELIVERED', 'CANCELLED'];
    String selectedStatus = booking['status']?.toString() ?? 'PENDING';

    showProfessionalDialog(
      context: context,
      title: 'تحديث حالة الحجز',
      content: StatefulBuilder(
        builder: (context, setState) {
          return DropdownButtonFormField<String>(
            initialValue: selectedStatus,
            decoration: InputDecoration(
              labelText: 'الحالة الجديدة',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            items: statuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getStatusText(status)),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedStatus = value!),
          );
        },
      ),
      onConfirm: () async {
        try {
          await widget.apiService.patch(
            '${ApiConstants.bookings}/${booking['id']}/status',
            body: {'status': selectedStatus},
          );
          if (mounted) {
            Navigator.pop(context);
            _loadBookings();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الحالة بنجاح')));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
          }
        }
      },
    );
  }

  Future<void> _showInvoiceForBooking(Map<String, dynamic> booking) async {
    final vehicleId = booking['vehicleId']?.toString();
    if (vehicleId == null || vehicleId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد معرف مركبة لهذا الحجز')));
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final vehicleResponse = await widget.apiService.get(ApiConstants.vehicle(vehicleId));
      final publicCarId = (vehicleResponse is Map)
          ? (vehicleResponse['publicCarId']?.toString() ?? vehicleResponse['public_car_id']?.toString())
          : null;

      // Fetch customer details to get full customer data
      final customerId = booking['customerId']?.toString();
      Map<String, dynamic>? customerData;
      if (customerId != null && customerId.isNotEmpty) {
        try {
          final customerResponse = await widget.apiService.get('${ApiConstants.customers}/$customerId');
          if (customerResponse is Map<String, dynamic>) {
            customerData = customerResponse;
          }
        } catch (e) {
          print('Error fetching customer data: $e');
        }
      }

      if (publicCarId == null || publicCarId.isEmpty) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد كود تتبع لهذه المركبة')));
        }
        return;
      }

      final publicResponse = await widget.apiService.get('/public/car/$publicCarId');

      if (mounted) Navigator.pop(context);

      if (publicResponse is Map<String, dynamic>) {
        publicResponse['booking'] = {
          ...(publicResponse['booking'] is Map ? publicResponse['booking'] as Map<String, dynamic> : <String, dynamic>{}),
          'id': booking['id'],
          'status': booking['status'],
          'notes': booking['notes'],
          'createdAt': booking['createdAt'],
          'estimatedCompletionDate': booking['estimatedCompletionDate'],
        };
        // Add bookingId at top level for invoice screen
        publicResponse['bookingId'] = booking['id'];
        publicResponse['id'] = booking['id'];
        // Add full customer data if available
        if (customerData != null) {
          publicResponse['customer'] = customerData;
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceScreen(invoiceData: publicResponse),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل في تحميل بيانات الفاتورة')));
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل الفاتورة: $e')));
      }
    }
  }

  Future<void> _deleteBooking(String? id) async {
    if (id == null) return;

    final confirmed = await showProfessionalDialog<bool>(
      context: context,
      title: 'تأكيد الحذف',
      content: const Text('هل أنت متأكد من حذف هذا الحجز؟'),
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      onConfirm: () => Navigator.pop(context, true),
    );

    if (confirmed == true) {
      try {
        await widget.apiService.delete('${ApiConstants.bookings}/$id');
        _loadBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الحجز بنجاح')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
        }
      }
    }
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onInvoice;
  final VoidCallback onEdit;
  final VoidCallback onUpdateStatus;
  final VoidCallback onDelete;

  const _BookingCard({
    required this.booking,
    required this.onInvoice,
    required this.onEdit,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.grey;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'WAITING_PARTS':
        return Colors.orange;
      case 'READY':
        return Colors.green;
      case 'DELIVERED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.pending_rounded;
      case 'IN_PROGRESS':
        return Icons.build_rounded;
      case 'WAITING_PARTS':
        return Icons.inventory_2_rounded;
      case 'READY':
        return Icons.check_circle_rounded;
      case 'DELIVERED':
        return Icons.local_shipping_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'معلق';
      case 'IN_PROGRESS':
        return 'قيد التنفيذ';
      case 'WAITING_PARTS':
        return 'بانتظار القطع';
      case 'READY':
        return 'جاهز';
      case 'DELIVERED':
        return 'تم التسليم';
      case 'CANCELLED':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    if (date is String) {
      try {
        final dateTime = DateTime.parse(date);
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } catch (e) {
        return date;
      }
    }
    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String? ?? '';
    final statusColor = _getStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_getStatusIcon(status), color: statusColor, size: 20),
        ),
        title: Text(
          'حجز #${booking['id']?.toString().substring(0, 8) ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(_formatDate(booking['createdAt']), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_getStatusText(status), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('معرف العميل', booking['customerId']?.toString() ?? ''),
                const SizedBox(height: 6),
                _buildDetailRow('معرف المركبة', booking['vehicleId']?.toString() ?? ''),
                if (booking['notes'] != null && booking['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildDetailRow('ملاحظات', booking['notes'].toString()),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onInvoice,
                      icon: const Icon(Icons.receipt_long_rounded, size: 14),
                      label: const Text('الفاتورة'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('تعديل'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onUpdateStatus,
                      icon: const Icon(Icons.update_rounded, size: 14),
                      label: const Text('الحالة'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_rounded, size: 14),
                      label: const Text('حذف'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text('$label:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
