import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/error_handler.dart';
import 'invoice_screen.dart';

class QuickBookingScreen extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback? onBookingCreated;

  const QuickBookingScreen({
    super.key,
    required this.apiService,
    this.onBookingCreated,
  });

  @override
  State<QuickBookingScreen> createState() => _QuickBookingScreenState();
}

class _QuickBookingScreenState extends State<QuickBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Customer Selection
  String? _selectedCustomerId;
  List<Map<String, dynamic>> _customers = [];
  bool _isLoadingCustomers = false;
  
  // Vehicle Selection
  String? _selectedVehicleId;
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoadingVehicles = false;
  bool _showAddVehicleOption = false;
  
  // Services
  List<Map<String, dynamic>> _availableServices = [];
  final List<String> _selectedServiceIds = [];
  bool _isLoadingServices = false;
  
  // Notes
  final _notesController = TextEditingController();
  
  bool _isCreatingBooking = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadServices();
  }

  // Vehicle Form Controllers
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _vehicleFormKey = GlobalKey<FormState>();
  bool _isAddingVehicle = false;

  @override
  void dispose() {
    _notesController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _vehiclePlateController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      print('Loading customers from: ${ApiConstants.customers}');
      final response = await widget.apiService.get(ApiConstants.customers);
      print('Response type: ${response.runtimeType}');
      print('Response: $response');
      
      List<dynamic> customersList = [];
      
      if (response is List) {
        customersList = response;
      } else if (response is Map<String, dynamic>) {
        // Handle wrapped response with 'data' field
        if (response['data'] is List) {
          customersList = response['data'] as List<dynamic>;
        }
      }
      
      setState(() {
        _customers = List<Map<String, dynamic>>.from(customersList);
        print('Loaded ${_customers.length} customers');
      });
    } catch (e) {
      print('Error loading customers: $e');
      if (mounted) {
        ErrorHandler.showError(context, ErrorHandler.parseError(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCustomers = false);
      }
    }
  }

  Future<void> _loadServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final response = await widget.apiService.get(ApiConstants.services);
      
      List<dynamic> servicesList = [];
      
      if (response is List) {
        servicesList = response;
      } else if (response is Map<String, dynamic>) {
        if (response['data'] is List) {
          servicesList = response['data'] as List<dynamic>;
        }
      }
      
      setState(() {
        _availableServices = List<Map<String, dynamic>>.from(servicesList);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الخدمات: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingServices = false);
      }
    }
  }

  Future<void> _loadVehicles(String customerId) async {
    setState(() => _isLoadingVehicles = true);
    try {
      // Filter vehicles by customer ID
      final allVehiclesResponse = await widget.apiService.get(ApiConstants.vehicles);
      
      List<dynamic> vehiclesList = [];
      
      if (allVehiclesResponse is List) {
        vehiclesList = allVehiclesResponse;
      } else if (allVehiclesResponse is Map<String, dynamic>) {
        if (allVehiclesResponse['data'] is List) {
          vehiclesList = allVehiclesResponse['data'] as List<dynamic>;
        }
      }
      
      final customerVehicles = vehiclesList
          .where((v) => v['customerId'] == customerId)
          .toList();
      
      setState(() {
        _vehicles = List<Map<String, dynamic>>.from(customerVehicles);
        _selectedVehicleId = null;
        _showAddVehicleOption = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل السيارات: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingVehicles = false);
      }
    }
  }

  Future<void> _createBooking() async {
    if (_selectedCustomerId == null || _selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار العميل والسيارة')),
      );
      return;
    }

    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار خدمة واحدة على الأقل')),
      );
      return;
    }

    setState(() => _isCreatingBooking = true);

    try {
      // Create booking - convert service IDs to service objects with price
      final servicesData = _selectedServiceIds.map((serviceId) {
        final service = _availableServices.firstWhere(
          (s) => s['id']?.toString() == serviceId,
          orElse: () => {},
        );
        return {
          'serviceId': serviceId,
          'priceSYP': service['priceSYP'] ?? service['price_syp'] ?? 0,
        };
      }).toList();

      final bookingResponse = await widget.apiService.post(ApiConstants.bookings, {
        'customerId': _selectedCustomerId,
        'vehicleId': _selectedVehicleId,
        'services': servicesData,
        'notes': _notesController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الحجز بنجاح')),
        );
        
        if (widget.onBookingCreated != null) {
          widget.onBookingCreated!();
        }

        // Fetch invoice data
        final bookingId = bookingResponse['id']?.toString();
        if (bookingId != null) {
          try {
            print('Fetching invoice for booking: $bookingId');
            final invoiceResponse = await widget.apiService.get('${ApiConstants.bookings}/$bookingId/invoice');
            print('Invoice response type: ${invoiceResponse.runtimeType}');
            print('Invoice response: $invoiceResponse');
            
            Map<String, dynamic> invoiceData = {};
            if (invoiceResponse is Map<String, dynamic>) {
              invoiceData = invoiceResponse;
            } else if (invoiceResponse is Map && invoiceResponse['data'] is Map) {
              invoiceData = invoiceResponse['data'] as Map<String, dynamic>;
            }
            
            print('Final invoice data: $invoiceData');
            
            // Push invoice screen (don't replace, so back button works)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => InvoiceScreen(invoiceData: invoiceData),
              ),
            );
          } catch (e) {
            print('Error fetching invoice: $e');
            // If invoice fetch fails, just go back
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إنشاء الحجز: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingBooking = false);
      }
    }
  }

  Future<void> _showAddVehicleDialog() async {
    // Clear previous form data
    _vehicleMakeController.clear();
    _vehicleModelController.clear();
    _vehicleYearController.clear();
    _vehiclePlateController.clear();
    _vehicleColorController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة سيارة جديدة'),
          content: SingleChildScrollView(
            child: Form(
              key: _vehicleFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _vehicleMakeController,
                    decoration: const InputDecoration(
                      labelText: 'الماركة *',
                      hintText: 'مثال: Toyota',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الماركة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleModelController,
                    decoration: const InputDecoration(
                      labelText: 'الموديل *',
                      hintText: 'مثال: Corolla',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الموديل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleYearController,
                    decoration: const InputDecoration(
                      labelText: 'السنة',
                      hintText: 'مثال: 2020',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final year = int.tryParse(value);
                        if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                          return 'يرجى إدخال سنة صحيحة';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehiclePlateController,
                    decoration: const InputDecoration(
                      labelText: 'رقم اللوحة *',
                      hintText: 'مثال: دمشق 123456',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم اللوحة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleColorController,
                    decoration: const InputDecoration(
                      labelText: 'اللون',
                      hintText: 'مثال: أبيض',
                      prefixIcon: Icon(Icons.palette),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _isAddingVehicle
                  ? null
                  : () async {
                      if (_vehicleFormKey.currentState!.validate()) {
                        setDialogState(() => _isAddingVehicle = true);
                        
                        try {
                          final vehicleResponse = await widget.apiService.post(
                            ApiConstants.vehicles,
                            {
                              'customerId': _selectedCustomerId,
                              'make': _vehicleMakeController.text.trim(),
                              'model': _vehicleModelController.text.trim(),
                              'year': _vehicleYearController.text.trim().isEmpty
                                  ? null
                                  : int.tryParse(_vehicleYearController.text.trim()),
                              'licensePlate': _vehiclePlateController.text.trim(),
                              'color': _vehicleColorController.text.trim().isEmpty
                                  ? null
                                  : _vehicleColorController.text.trim(),
                            },
                          );

                          if (vehicleResponse['id'] != null) {
                            // Reload vehicles for the customer
                            await _loadVehicles(_selectedCustomerId!);
                            
                            // Auto-select the new vehicle
                            setState(() {
                              _selectedVehicleId = vehicleResponse['id']?.toString();
                            });

                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إضافة السيارة بنجاح')),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('خطأ في إضافة السيارة: $e')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setDialogState(() => _isAddingVehicle = false);
                          }
                        }
                      }
                    },
              child: _isAddingVehicle
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز لعميل مسجل مسبقا'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر العميل',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingCustomers)
                        const Center(child: CircularProgressIndicator())
                      else if (_customers.isEmpty)
                        const Center(child: Text('لا يوجد عملاء مسجلين'))
                      else
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'اختر العميل',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedCustomerId,
                          items: _customers.map((customer) {
                            return DropdownMenuItem<String>(
                              value: customer['id']?.toString(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    customer['fullName'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    customer['phone'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? customerId) {
                            if (customerId != null) {
                              setState(() {
                                _selectedCustomerId = customerId;
                                _selectedVehicleId = null;
                                _vehicles = [];
                              });
                              _loadVehicles(customerId);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Vehicle Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر السيارة',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedCustomerId == null)
                        const Center(
                          child: Text('يرجى اختيار عميل أولاً'),
                        )
                      else if (_isLoadingVehicles)
                        const Center(child: CircularProgressIndicator())
                      else if (_vehicles.isEmpty && !_showAddVehicleOption)
                        const Center(
                          child: Text('لا توجد سيارات لهذا العميل'),
                        )
                      else
                        Column(
                          children: [
                            if (_vehicles.isNotEmpty)
                              Autocomplete<String>(
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  return _vehicles.map((vehicle) => vehicle['id']?.toString() ?? '');
                                },
                                displayStringForOption: (String vehicleId) {
                                  final vehicle = _vehicles.firstWhere(
                                    (v) => v['id']?.toString() == vehicleId,
                                    orElse: () => {},
                                  );
                                  return '${vehicle['make']} ${vehicle['model']} - ${vehicle['licensePlate'] ?? ''}';
                                },
                                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                  return TextField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      labelText: 'اختر سيارة',
                                      border: OutlineInputBorder(),
                                    ),
                                  );
                                },
                                onSelected: (String vehicleId) {
                                  setState(() {
                                    _selectedVehicleId = vehicleId;
                                  });
                                },
                              ),
                            if (_showAddVehicleOption)
                              const SizedBox(height: 16),
                            if (_showAddVehicleOption)
                              OutlinedButton.icon(
                                onPressed: _showAddVehicleDialog,
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('إضافة سيارة جديدة'),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Services Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر الخدمات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingServices)
                        const Center(child: CircularProgressIndicator())
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableServices.map((service) {
                            final isSelected = _selectedServiceIds.contains(service['id']?.toString());
                            return FilterChip(
                              label: Text(service['name'] ?? 'خدمة'),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedServiceIds.add(service['id']?.toString() ?? '');
                                  } else {
                                    _selectedServiceIds.remove(service['id']?.toString());
                                  }
                                });
                              },
                              selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              checkmarkColor: Theme.of(context).colorScheme.primary,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملاحظات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'ملاحظات إضافية (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreatingBooking ? null : _createBooking,
                  child: _isCreatingBooking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('إنشاء الحجز'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
