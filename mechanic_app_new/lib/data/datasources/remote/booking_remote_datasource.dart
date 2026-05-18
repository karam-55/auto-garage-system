import '../../models/booking_model.dart';
import '../../models/mechanic_assignment_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/exceptions.dart';

class BookingRemoteDataSource {
  final DioClient _dioClient;

  BookingRemoteDataSource(this._dioClient);

  Future<List<BookingModel>> getAvailableBookings() async {
    try {
      final response = await _dioClient.get('/api/mechanics/available-bookings');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get available bookings');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  Future<List<MechanicAssignmentModel>> getMyAssignments(String mechanicUserId) async {
    try {
      final response = await _dioClient.get('/api/mechanics/my-assignments');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => MechanicAssignmentModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get my assignments');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  Future<MechanicAssignmentModel> assignBooking(String bookingId, String mechanicUserId) async {
    try {
      final response = await _dioClient.post(
        '/api/mechanics/assign',
        data: {'bookingId': bookingId},
      );

      if (response.statusCode == 200) {
        return MechanicAssignmentModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to assign booking');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await _dioClient.patch(
        '/api/mechanics/assignments/$bookingId/status',
        data: {'status': status},
      );

      return response.statusCode == 200;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
