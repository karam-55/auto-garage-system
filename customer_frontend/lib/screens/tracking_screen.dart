import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/booking.dart';
import '../models/booking_service.dart';
import '../models/part_suggestion.dart';

class TrackingScreen extends StatefulWidget {
  final String publicToken;
  
  const TrackingScreen({super.key, required this.publicToken});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final ApiService _apiService = ApiService();
  Booking? _booking;
  List<BookingService> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    try {
      final response = await _apiService.get('${ApiConstants.publicBooking}${widget.publicToken}');
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('Invalid response format: expected JSON object');
        }
        final data = decoded;
        final bookingData = data['booking'];
        final servicesData = data['services'];
        if (bookingData == null) {
          throw Exception('Missing booking data in response');
        }
        setState(() {
          _booking = Booking.fromJson(bookingData as Map<String, dynamic>);
          _services = (servicesData is List ? servicesData : [])
              .map((json) => BookingService.fromJson(json as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'فشل تحميل تفاصيل الحجز';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع حالة السيارة'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _booking != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: 24),
                          _buildServicesCard(),
                          const SizedBox(height: 24),
                          _buildTimeline(),
                          const SizedBox(height: 24),
                          _buildQRCode(),
                        ],
                      ),
                    )
                  : const Center(child: Text('لا توجد بيانات')),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حالة الحجز',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(_booking!.status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _booking!.statusDisplay,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_booking!.notes != null)
              Text('ملاحظات: ${_booking!.notes}'),
            Text('رقم الحجز: ${_booking!.id.substring(0, 8)}'),
            Text('تاريخ الإنشاء: ${_formatDate(_booking!.createdAt)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard() {
    final total = _services.fold<double>(0, (sum, service) => sum + service.priceSYP);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الخدمات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._services.map((service) => ListTile(
              title: Text('خدمة #${service.serviceId}'),
              trailing: Text('${service.priceSYP} ل.س'),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المجموع التقريبي',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$total ل.س',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الجدول الزمني',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _TimelineItem(
              title: 'تم استلام الحجز',
              isCompleted: true,
              isCurrent: false,
            ),
            _TimelineItem(
              title: 'قيد العمل',
              isCompleted: _booking!.status == 'IN_PROGRESS' || 
                          _booking!.status == 'WAITING_PARTS' ||
                          _booking!.status == 'READY' ||
                          _booking!.status == 'DELIVERED',
              isCurrent: _booking!.status == 'IN_PROGRESS',
            ),
            _TimelineItem(
              title: 'بانتظار القطع',
              isCompleted: _booking!.status == 'WAITING_PARTS' ||
                          _booking!.status == 'READY' ||
                          _booking!.status == 'DELIVERED',
              isCurrent: _booking!.status == 'WAITING_PARTS',
            ),
            _TimelineItem(
              title: 'جاهزة',
              isCompleted: _booking!.status == 'READY' || _booking!.status == 'DELIVERED',
              isCurrent: _booking!.status == 'READY',
            ),
            _TimelineItem(
              title: 'تم التسليم',
              isCompleted: _booking!.status == 'DELIVERED',
              isCurrent: _booking!.status == 'DELIVERED',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'رمز QR للتتبع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: QrImageView(
                data: widget.publicToken,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.publicToken,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.grey;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'WAITING_PARTS':
        return Colors.orange;
      case 'READY':
        return Colors.green;
      case 'DELIVERED':
        return Colors.purple;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isCurrent;

  const _TimelineItem({
    required this.title,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? Colors.blue
                : isCompleted
                    ? Colors.green
                    : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: isCurrent
                ? Colors.blue
                : isCompleted
                    ? Colors.black
                    : Colors.grey,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
