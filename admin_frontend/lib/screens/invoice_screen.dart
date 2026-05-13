import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:ui' as ui;

class InvoiceScreen extends StatefulWidget {
  final Map<String, dynamic> invoiceData;
  final bool showPrintButton;

  const InvoiceScreen({
    super.key,
    required this.invoiceData,
    this.showPrintButton = true,
  });

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isPrinting = false;

  Map<String, dynamic> get _data => widget.invoiceData;

  String get _customerName {
    final customer = _data['customer'] as Map<String, dynamic>?;
    return customer?['fullName']?.toString() ??
        customer?['full_name']?.toString() ??
        'غير معروف';
  }

  String get _customerPhone {
    final customer = _data['customer'] as Map<String, dynamic>?;
    return customer?['phone']?.toString() ?? '';
  }

  String get _vehicleName {
    final vehicle = _data['vehicle'] as Map<String, dynamic>?;
    final make = vehicle?['make']?.toString() ?? '';
    final model = vehicle?['model']?.toString() ?? '';
    return '$make $model'.trim();
  }

  String get _licensePlate {
    final vehicle = _data['vehicle'] as Map<String, dynamic>?;
    return vehicle?['licensePlate']?.toString() ??
        vehicle?['license_plate']?.toString() ??
        'غير متوفر';
  }

  int? get _vehicleYear {
    final vehicle = _data['vehicle'] as Map<String, dynamic>?;
    final year = vehicle?['year'];
    if (year is int) return year;
    if (year is String) return int.tryParse(year);
    return null;
  }

  String get _publicCarId {
    final vehicle = _data['vehicle'] as Map<String, dynamic>?;
    return vehicle?['publicCarId']?.toString() ??
        vehicle?['public_car_id']?.toString() ??
        '';
  }

  String get _bookingId {
    final booking = _data['booking'] as Map<String, dynamic>?;
    return booking?['id']?.toString() ?? _data['id']?.toString() ?? '';
  }

  String get _status {
    final booking = _data['booking'] as Map<String, dynamic>?;
    return booking?['status']?.toString() ?? _data['status']?.toString() ?? 'PENDING';
  }

  String get _notes {
    final booking = _data['booking'] as Map<String, dynamic>?;
    return booking?['notes']?.toString() ?? _data['notes']?.toString() ?? '';
  }

  DateTime? get _createdAt {
    final booking = _data['booking'] as Map<String, dynamic>?;
    final raw = booking?['createdAt'] ?? booking?['created_at'] ?? _data['createdAt'];
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> get _services {
    final services = _data['services'];
    if (services is List) {
      return List<Map<String, dynamic>>.from(services);
    }
    return [];
  }

  double get _total {
    double sum = 0;
    for (final s in _services) {
      final price = s['priceSYP'] ?? s['price_syp'] ?? 0;
      sum += (price is num) ? price.toDouble() : 0;
    }
    return sum;
  }

  String get _trackingUrl {
    const base = 'https://auto-garage-customer-frontend.pages.dev';
    if (_publicCarId.isEmpty) return base;
    return '$base?car=$_publicCarId';
  }

  static const Map<String, String> _statusLabels = {
    'PENDING': 'قيد الانتظار',
    'IN_PROGRESS': 'جاري العمل',
    'WAITING_PARTS': 'بانتظار القطع',
    'READY': 'جاهز',
    'DELIVERED': 'تم التسليم',
    'CANCELLED': 'ملغي',
  };

  static const Map<String, Color> _statusColors = {
    'PENDING': Colors.orange,
    'IN_PROGRESS': Colors.blue,
    'WAITING_PARTS': Colors.deepOrange,
    'READY': Colors.green,
    'DELIVERED': Colors.grey,
    'CANCELLED': Colors.red,
  };

  Future<void> _printInvoice() async {
    setState(() => _isPrinting = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(0),
          build: (context) {
            return pw.Center(
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الطباعة: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[_status] ?? Colors.orange;
    final statusLabel = _statusLabels[_status] ?? _status;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('فاتورة الحجز'),
        actions: [
          if (widget.showPrintButton)
            IconButton(
              icon: _isPrinting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.print_rounded),
              onPressed: _isPrinting ? null : _printInvoice,
              tooltip: 'طباعة',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: RepaintBoundary(
            key: _repaintKey,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'فاتورة حجز',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'رقم: ${_bookingId.isNotEmpty ? _bookingId.substring(0, _bookingId.length > 8 ? 8 : _bookingId.length) : '---'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _createdAt != null
                              ? 'التاريخ: ${_createdAt!.day}/${_createdAt!.month}/${_createdAt!.year}'
                              : '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Customer & Vehicle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('بيانات العميل'),
                        _buildInfoRow(Icons.person_rounded, 'الاسم', _customerName),
                        if (_customerPhone.isNotEmpty)
                          _buildInfoRow(Icons.phone_rounded, 'الهاتف', _customerPhone),
                        const Divider(height: 32, color: Color(0xFFE2E8F0)),
                        _buildSectionTitle('بيانات المركبة'),
                        _buildInfoRow(Icons.directions_car_rounded, 'المركبة', _vehicleName),
                        _buildInfoRow(Icons.confirmation_number_rounded, 'رقم اللوحة', _licensePlate),
                        if (_vehicleYear != null)
                          _buildInfoRow(Icons.calendar_today_rounded, 'السنة', _vehicleYear.toString()),
                      ],
                    ),
                  ),

                  // Services
                  if (_services.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('الخدمات'),
                          const SizedBox(height: 8),
                          ..._services.map((s) => _buildServiceRow(s)),
                        ],
                      ),
                    ),
                  ],

                  // Notes
                  if (_notes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('ملاحظات'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Text(
                              _notes,
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Total
                  if (_services.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الإجمالي',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_total.toStringAsFixed(0)} ل.س',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // QR Code
                  if (_publicCarId.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildSectionTitle('كود التتبع'),
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                children: [
                                  QrImageView(
                                    data: _trackingUrl,
                                    version: QrVersions.auto,
                                    size: 160,
                                    backgroundColor: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _publicCarId,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'امسح الكود لمتابعة حالة السيارة',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'شكراً لثقتكم بنا',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(Map<String, dynamic> service) {
    final name = service['serviceName']?.toString() ??
        service['service_name']?.toString() ??
        service['name']?.toString() ??
        'خدمة';
    final desc = service['serviceDescription']?.toString() ??
        service['service_description']?.toString() ??
        '';
    final priceRaw = service['priceSYP'] ?? service['price_syp'] ?? 0;
    final price = (priceRaw is num) ? priceRaw.toDouble() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (desc.isNotEmpty)
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${price.toStringAsFixed(0)} ل.س',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
