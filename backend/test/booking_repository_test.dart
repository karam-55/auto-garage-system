import 'package:test/test.dart';
import '../lib/domain/entities/booking.dart';
import '../lib/domain/entities/booking_status.dart';

void main() {
  group('Booking Entity', () {
    test('creates a booking with valid data', () {
      final booking = Booking(
        id: 'test-id',
        customerId: 'customer-123',
        vehicleId: 'vehicle-123',
        status: BookingStatus.pending,
        customerName: 'Test Customer',
        vehicleMake: 'Toyota',
        vehicleModel: 'Camry',
        licensePlate: 'ABC123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.id, equals('test-id'));
      expect(booking.customerId, equals('customer-123'));
      expect(booking.status, equals(BookingStatus.pending));
      expect(booking.customerName, equals('Test Customer'));
    });

    test('converts booking to JSON and back', () {
      final booking = Booking(
        id: 'test-id',
        customerId: 'customer-123',
        vehicleId: 'vehicle-123',
        status: BookingStatus.inProgress,
        customerName: 'Test Customer',
        vehicleMake: 'Toyota',
        vehicleModel: 'Camry',
        licensePlate: 'ABC123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = booking.toJson();
      final restored = Booking.fromJson(json);

      expect(restored.id, equals(booking.id));
      expect(restored.customerId, equals(booking.customerId));
      expect(restored.status, equals(booking.status));
    });

    test('copyWith creates a new booking with updated fields', () {
      final booking = Booking(
        id: 'test-id',
        customerId: 'customer-123',
        vehicleId: 'vehicle-123',
        status: BookingStatus.pending,
        customerName: 'Test Customer',
        vehicleMake: 'Toyota',
        vehicleModel: 'Camry',
        licensePlate: 'ABC123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = booking.copyWith(status: BookingStatus.ready);

      expect(updated.id, equals(booking.id));
      expect(updated.status, equals(BookingStatus.ready));
    });
  });
}
