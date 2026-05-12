import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/widgets/professional_dialog.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class CreateBookingScreen extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback? onBookingCreated;

  const CreateBookingScreen({
    super.key,
    required this.apiService,
    this.onBookingCreated,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Customer Data
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();

  // Vehicle Data
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _vehicleColorController = TextEditingController();

  // Booking Data
  final _bookingNotesController = TextEditingController();
  DateTime? _preferredDate;

  // Services
  List<Map<String, dynamic>> _selectedServices = [];
  double _totalPrice = 0.0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _vehiclePlateController.dispose();
    _vehicleColorController.dispose();
    _bookingNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final response = await widget.apiService.get(ApiConstants.services);
      if (response is List) {
        setState(() {
          _selectedServices = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الخدمات: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _createBooking() async {
    // Validate all required fields
    if (_customerNameController.text.isEmpty ||
        _customerPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم العميل ورقم الهاتف'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _tabController.animateTo(0);
      return;
    }

    if (_vehicleMakeController.text.isEmpty ||
        _vehicleModelController.text.isEmpty ||
        _vehiclePlateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال بيانات المركبة'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _tabController.animateTo(1);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Create Customer
      final customerResponse = await widget.apiService.post(ApiConstants.customers, {
        'fullName': _customerNameController.text.trim(),
        'phone': _customerPhoneController.text.trim(),
        'address': _customerAddressController.text.trim(),
      });

      if (customerResponse is! Map || customerResponse['id'] == null) {
        throw Exception('فشل في إنشاء العميل');
      }

      final customerId = customerResponse['id'].toString();

      // Step 2: Create Vehicle
      final vehicleResponse = await widget.apiService.post(ApiConstants.vehicles, {
        'customerId': customerId,
        'make': _vehicleMakeController.text.trim(),
        'model': _vehicleModelController.text.trim(),
        'year': _vehicleYearController.text.trim().isEmpty 
            ? null 
            : int.tryParse(_vehicleYearController.text.trim()),
        'licensePlate': _vehiclePlateController.text.trim(),
        'color': _vehicleColorController.text.trim().isEmpty 
            ? null 
            : _vehicleColorController.text.trim(),
      });

      if (vehicleResponse is! Map || vehicleResponse['id'] == null) {
        throw Exception('فشل في إنشاء المركبة');
      }

      final vehicleId = vehicleResponse['id'].toString();

      // Step 3: Create Booking with Services
      final bookingData = {
        'customerId': customerId,
        'vehicleId': vehicleId,
        'services': _selectedServices.map((s) => {
          'serviceId': s['id'],
          'priceSYP': s['priceSYP'],
        }).toList(),
        'notes': _bookingNotesController.text.trim(),
      };

      // Only add preferredDate if it's not null
      if (_preferredDate != null) {
        bookingData['estimatedCompletionDate'] = _preferredDate!.toIso8601String();
      }

      final bookingResponse = await widget.apiService.post(ApiConstants.bookings, bookingData);

      if (bookingResponse is! Map || bookingResponse['id'] == null) {
        throw Exception('فشل في إنشاء الحجز');
      }

      final bookingId = bookingResponse['id'].toString();
      final publicCarId = bookingResponse['publicCarId']?.toString();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحجز بنجاح'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Show QR Code dialog if publicCarId is available
        if (publicCarId != null && publicCarId.isNotEmpty) {
          _showQRCodeDialog(publicCarId, bookingId);
        } else {
          Navigator.pop(context);
          widget.onBookingCreated?.call();
        }
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleService(Map<String, dynamic> service) {
    setState(() {
      if (_selectedServices.any((s) => s['id'] == service['id'])) {
        _selectedServices.removeWhere((s) => s['id'] == service['id']);
        _totalPrice -= (service['priceSYP'] as num).toDouble();
      } else {
        _selectedServices.add(service);
        _totalPrice += (service['priceSYP'] as num).toDouble();
      }
    });
  }

  void _showQRCodeDialog(String publicCarId, String bookingId) {
    // Customer frontend URL
    const customerFrontendUrl = String.fromEnvironment(
      'CUSTOMER_FRONTEND_URL',
      defaultValue: 'https://auto-garage-customer-frontend.pages.dev',
    );
    final trackingUrl = '$customerFrontendUrl?car=$publicCarId';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم إنشاء الحجز بنجاح'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('امسح الكود لتتبع حالة الحجز'),
            const SizedBox(height: 20),
            QrImageView(
              data: trackingUrl,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            Text(
              'رقم الحجز: $bookingId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'كود التتبع: $publicCarId',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onBookingCreated?.call();
            },
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حجز جديد'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'العميل'),
            Tab(text: 'المركبة'),
            Tab(text: 'الخدمات'),
            Tab(text: 'التفاصيل'),
            Tab(text: 'التأكيد'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCustomerTab(),
            _buildVehicleTab(),
            _buildServicesTab(),
            _buildDetailsTab(),
            _buildConfirmTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.person_add_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'بيانات العميل',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _customerNameController,
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: Icon(Icons.person_rounded),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerPhoneController,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerAddressController,
            decoration: const InputDecoration(
              labelText: 'العنوان',
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
            maxLines: 2,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('التالي'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.directions_car_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'بيانات المركبة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _vehicleMakeController,
                  decoration: const InputDecoration(
                    labelText: 'الشركة المصنعة',
                    prefixIcon: Icon(Icons.business_rounded),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _vehicleModelController,
                  decoration: const InputDecoration(
                    labelText: 'الموديل',
                    prefixIcon: Icon(Icons.car_repair_rounded),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _vehicleYearController,
                  decoration: const InputDecoration(
                    labelText: 'السنة',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _vehiclePlateController,
                  decoration: const InputDecoration(
                    labelText: 'رقم اللوحة',
                    prefixIcon: Icon(Icons.confirmation_number_rounded),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _vehicleColorController,
            decoration: const InputDecoration(
              labelText: 'اللون',
              prefixIcon: Icon(Icons.palette_rounded),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('السابق'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(2),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('التالي'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.build_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'اختر الخدمات',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: FutureBuilder(
              future: widget.apiService.get(ApiConstants.services),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }
                final services = snapshot.data is List
                    ? List<Map<String, dynamic>>.from(snapshot.data as List)
                    : <Map<String, dynamic>>[];
                if (services.isEmpty) {
                  return const Center(child: Text('لا توجد خدمات'));
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    final isSelected = _selectedServices.any((s) => s['id'] == service['id']);
                    return GestureDetector(
                      onTap: () => _toggleService(service),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                service['name'] ?? '',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${service['priceSYP'] ?? 0} ل.س',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي المختار:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '$_totalPrice ل.س',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('السابق'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(3),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('التالي'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.description_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'تفاصيل إضافية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 32),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _preferredDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _preferredDate != null
                        ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'
                        : 'اختر التاريخ المفضل',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bookingNotesController,
            decoration: const InputDecoration(
              labelText: 'ملاحظات إضافية',
              prefixIcon: Icon(Icons.note_rounded),
            ),
            maxLines: 4,
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(2),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('السابق'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(4),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('التالي'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.check_circle_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'تأكيد الحجز',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 32),
          _buildSummaryCard('العميل', _customerNameController.text, Icons.person_rounded),
          const SizedBox(height: 12),
          _buildSummaryCard('المركبة', '${_vehicleMakeController.text} ${_vehicleModelController.text}', Icons.directions_car_rounded),
          const SizedBox(height: 12),
          _buildSummaryCard('الخدمات المختارة', '${_selectedServices.length} خدمة', Icons.build_rounded),
          const SizedBox(height: 12),
          _buildSummaryCard('الإجمالي', '$_totalPrice ل.س', Icons.attach_money_rounded),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(3),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('السابق'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createBooking,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('إنشاء الحجز'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
