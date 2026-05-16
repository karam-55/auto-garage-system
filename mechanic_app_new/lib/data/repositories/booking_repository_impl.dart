import '../../domain/entities/booking.dart';
import '../../domain/entities/mechanic_assignment.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/remote/booking_remote_datasource.dart';
import '../datasources/local/cache_datasource.dart';
import '../models/booking_model.dart';
import '../models/mechanic_assignment_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;
  final CacheDataSource _cacheDataSource;

  BookingRepositoryImpl(this._remoteDataSource, this._cacheDataSource);

  @override
  Future<List<Booking>> getAvailableBookings() async {
    try {
      // Check cache first (30 second expiry)
      final isExpired = await _cacheDataSource.isExpired('available_bookings', const Duration(seconds: 30));
      
      if (!isExpired) {
        final cachedData = await _cacheDataSource.getList('available_bookings');
        if (cachedData.isNotEmpty) {
          return cachedData.map((json) => BookingModel.fromJson(json).toEntity()).toList();
        }
      }

      // Fetch from remote
      final bookingModels = await _remoteDataSource.getAvailableBookings();
      final bookings = bookingModels.map((model) => model.toEntity()).toList();

      // Save to cache
      await _cacheDataSource.saveList('available_bookings', bookingModels.map((m) => m.toJson()).toList());
      await _cacheDataSource.setTimestamp('available_bookings');

      return bookings;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get available bookings: $e');
    }
  }

  @override
  Future<List<MechanicAssignment>> getMyAssignments(String mechanicUserId) async {
    try {
      // Check cache first (30 second expiry)
      final isExpired = await _cacheDataSource.isExpired('my_assignments', const Duration(seconds: 30));
      
      if (!isExpired) {
        final cachedData = await _cacheDataSource.getList('my_assignments');
        if (cachedData.isNotEmpty) {
          return cachedData.map((json) => MechanicAssignmentModel.fromJson(json).toEntity()).toList();
        }
      }

      // Fetch from remote
      final assignmentModels = await _remoteDataSource.getMyAssignments(mechanicUserId);
      final assignments = assignmentModels.map((model) => model.toEntity()).toList();

      // Save to cache
      await _cacheDataSource.saveList('my_assignments', assignmentModels.map((m) => m.toJson()).toList());
      await _cacheDataSource.setTimestamp('my_assignments');

      return assignments;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get my assignments: $e');
    }
  }

  @override
  Future<MechanicAssignment> assignBooking(String bookingId, String mechanicUserId) async {
    try {
      final assignmentModel = await _remoteDataSource.assignBooking(bookingId, mechanicUserId);
      final assignment = assignmentModel.toEntity();

      // Clear cache to force refresh
      await _cacheDataSource.remove('available_bookings');
      await _cacheDataSource.remove('my_assignments');

      return assignment;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to assign booking: $e');
    }
  }

  @override
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final success = await _remoteDataSource.updateBookingStatus(bookingId, status);

      if (success) {
        // Clear cache to force refresh
        await _cacheDataSource.remove('my_assignments');
      }

      return success;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to update booking status: $e');
    }
  }

  @override
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      // Check cache first (5 minute expiry)
      final cacheKey = 'booking_$bookingId';
      final isExpired = await _cacheDataSource.isExpired(cacheKey, const Duration(minutes: 5));
      
      if (!isExpired) {
        final cachedData = await _cacheDataSource.getString(cacheKey);
        if (cachedData != null) {
          return BookingModel.fromJson(cachedData as Map<String, dynamic>).toEntity();
        }
      }

      // This should be implemented in remote datasource
      // For now, return null
      return null;
    } catch (e) {
      throw ServerFailure('Failed to get booking: $e');
    }
  }
}
