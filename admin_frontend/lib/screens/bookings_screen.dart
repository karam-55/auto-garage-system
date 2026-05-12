import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/widgets/animated_card.dart';
import '../core/widgets/loading_screen.dart';
import '../core/widgets/professional_dialog.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import 'create_booking_screen.dart';

class BookingsScreen extends StatefulWidget {
  final ApiService apiService;

  const BookingsScreen({super.key, required this.apiService});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(ApiConstants.bookings);
      setState(() {
        final raw = response is List ? response : (response['data'] ?? []);
        _bookings = List<Map<String, dynamic>>.from(raw);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الحجوزات: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_searchQuery.isEmpty) return _bookings;
    return _bookings.where((booking) {
      final id = booking['id']?.toString().toLowerCase() ?? '';
      final status = booking['status']?.toString().toLowerCase() ?? '';
      return id.contains(_searchQuery.toLowerCase()) ||
          status.contains(_searchQuery.toLowerCase());
    }).toList();
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
                : _bookings.isEmpty
                    ? _buildEmptyState()
                    : _buildBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'إدارة الحجوزات',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث حجز...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateBooking(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة حجز كامل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddBookingDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('حجز سريع'),
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
            Icons.calendar_today_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حجوزات حالياً',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "إضافة حجز" لإنشاء حجز جديد',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddBookingDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة حجز'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildBookingCard(_filteredBookings[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String? ?? '';
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            _getStatusIcon(status),
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          'حجز #${booking['id']?.toString().substring(0, 8) ?? ''}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          _formatDate(booking['createdAt']),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusText(status),
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('معرف العميل', booking['customerId']?.toString() ?? ''),
                const SizedBox(height: 8),
                _buildDetailRow('معرف المركبة', booking['vehicleId']?.toString() ?? ''),
                if (booking['notes'] != null && booking['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('ملاحظات', booking['notes'].toString()),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showEditBookingDialog(context, booking),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('تعديل'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showUpdateStatusDialog(context, booking),
                      icon: const Icon(Icons.update_rounded, size: 18),
                      label: const Text('تحديث الحالة'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _deleteBooking(booking['id']),
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      label: const Text('حذف'),
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
          width: 120,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
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
                decoration: const InputDecoration(labelText: 'معرف العميل'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: vehicleIdController,
                decoration: const InputDecoration(labelText: 'معرف المركبة'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إضافة الحجز بنجاح'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطأ: $e'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
          decoration: const InputDecoration(labelText: 'ملاحظات'),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الحجز بنجاح'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: $e'),
                behavior: SnackBarBehavior.floating,
              ),
            );
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
            value: selectedStatus,
            decoration: const InputDecoration(labelText: 'الحالة الجديدة'),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الحالة بنجاح'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: $e'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الحجز بنجاح'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
