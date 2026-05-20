import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/pagination_result.dart';
import '../database/database_connection.dart';

class BookingRepositoryImpl implements BookingRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  BookingRepositoryImpl(this._db);

  @override
  Future<Booking> create(Booking booking) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          INSERT INTO bookings (id, customer_id, vehicle_id, status, public_token, notes, estimated_completion_date, created_at)
          VALUES (@id, @customerId, @vehicleId, @status, @publicToken, @notes, @estimatedCompletionDate, @createdAt)
          RETURNING *
        '''),
        parameters: {
          'id': booking.id.isEmpty ? _uuid.v4() : booking.id,
          'customerId': booking.customerId,
          'vehicleId': booking.vehicleId,
          'status': booking.status.value,
          'publicToken': booking.publicToken.isEmpty ? _generatePublicToken() : booking.publicToken,
          'notes': booking.notes,
          'estimatedCompletionDate': booking.estimatedCompletionDate,
          'createdAt': booking.createdAt,
        },
      );

      return _mapRowToBooking(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create booking: $e');
    }
  }

  @override
  Future<Booking> createWithServices(Booking booking, List<BookingService> services) async {
    try {
      return await _db.runInTransaction((session) async {
        // Create booking within transaction
        final publicToken = booking.publicToken.isEmpty
            ? _generatePublicToken()
            : booking.publicToken;
        final bookingId = booking.id.isEmpty ? _uuid.v4() : booking.id;

        final bookingResult = await session.execute(
          Sql.named('''
            INSERT INTO bookings (id, customer_id, vehicle_id, status, public_token, notes, estimated_completion_date, created_at)
            VALUES (@id, @customerId, @vehicleId, @status, @publicToken, @notes, @estimatedCompletionDate, @createdAt)
            RETURNING *
          '''),
          parameters: {
            'id': bookingId,
            'customerId': booking.customerId,
            'vehicleId': booking.vehicleId,
            'status': booking.status.value,
            'publicToken': publicToken,
            'notes': booking.notes,
            'estimatedCompletionDate': booking.estimatedCompletionDate,
            'createdAt': booking.createdAt,
          },
        );

        final createdBooking = _mapRowToBooking(bookingResult.first);

        // Create booking services within same transaction
        for (final service in services) {
          await session.execute(
            Sql.named('''
              INSERT INTO booking_services (id, booking_id, service_id, price_syp, notes)
              VALUES (@id, @bookingId, @serviceId, @priceSyp, @notes)
            '''),
            parameters: {
              'id': _uuid.v4(),
              'bookingId': createdBooking.id,
              'serviceId': service.serviceId,
              'priceSyp': service.priceSYP,
              'notes': service.notes,
            },
          );
        }

        return createdBooking;
      });
    } catch (e) {
      throw DatabaseException('Failed to create booking with services: $e');
    }
  }

  @override
  Future<Booking?> findById(String id) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM bookings WHERE id = @id'),
        parameters: {'id': id},
      );

      if (result.isEmpty) return null;
      return _mapRowToBooking(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find booking by id: $e');
    }
  }

  @override
  Future<Booking?> findByPublicToken(String publicToken) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM bookings WHERE public_token = @publicToken'),
        parameters: {'publicToken': publicToken},
      );

      if (result.isEmpty) return null;
      return _mapRowToBooking(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find booking by public token: $e');
    }
  }

  @override
  Future<List<Booking>> findByCustomerId(String customerId, {int? limit, int? offset}) async {
    try {
      final limitClause = limit != null ? 'LIMIT @limit' : '';
      final offsetClause = offset != null ? 'OFFSET @offset' : '';
      final result = await _db.execute(
        Sql.named('SELECT * FROM bookings WHERE customer_id = @customerId ORDER BY created_at DESC $limitClause $offsetClause'),
        parameters: {
          'customerId': customerId,
          'limit': ?limit,
          'offset': ?offset,
        },
      );
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find bookings by customer id: $e');
    }
  }

  @override
  Future<List<Booking>> findByVehicleId(String vehicleId, {int? limit, int? offset}) async {
    try {
      final limitClause = limit != null ? 'LIMIT @limit' : '';
      final offsetClause = offset != null ? 'OFFSET @offset' : '';
      final result = await _db.execute(
        Sql.named('SELECT * FROM bookings WHERE vehicle_id = @vehicleId ORDER BY created_at DESC $limitClause $offsetClause'),
        parameters: {
          'vehicleId': vehicleId,
          'limit': ?limit,
          'offset': ?offset,
        },
      );
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find bookings by vehicle id: $e');
    }
  }

  @override
  Future<List<Booking>> findAll({int? limit, int? offset}) async {
    try {
      final limitClause = limit != null ? 'LIMIT @limit' : '';
      final offsetClause = offset != null ? 'OFFSET @offset' : '';
      final result = await _db.execute(
        Sql.named('SELECT * FROM bookings ORDER BY created_at DESC $limitClause $offsetClause'),
        parameters: {
          'limit': ?limit,
          'offset': ?offset,
        },
      );
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all bookings: $e');
    }
  }

  @override
  Future<PaginationResult<Booking>> findAllPaginated({
    String? status,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = (page - 1) * limit;
      List<Booking> bookings;
      int totalCount;

      // Build WHERE clause dynamically
      final whereConditions = <String>[];
      final parameters = <String, dynamic>{};

      if (status != null && status.isNotEmpty) {
        whereConditions.add('status = @status');
        parameters['status'] = status;
      }

      if (customerId != null && customerId.isNotEmpty) {
        whereConditions.add('customer_id = @customerId');
        parameters['customerId'] = customerId;
      }

      if (fromDate != null) {
        whereConditions.add('created_at >= @fromDate');
        parameters['fromDate'] = fromDate.toUtc();
      }

      if (toDate != null) {
        whereConditions.add('created_at <= @toDate');
        parameters['toDate'] = toDate.toUtc();
      }

      if (search != null && search.isNotEmpty) {
        final searchPattern = '%$search%';
        whereConditions.add('(public_token ILIKE @search OR notes ILIKE @search)');
        parameters['search'] = searchPattern;
      }

      final whereClause = whereConditions.isNotEmpty ? 'WHERE ${whereConditions.join(' AND ')}' : '';

      // Get total count
      final countQuery = 'SELECT COUNT(*) as count FROM bookings $whereClause';
      final countResult = await _db.execute(
        Sql.named(countQuery),
        parameters: parameters,
      );
      totalCount = countResult.first[0] as int;

      // Get paginated data
      final dataQuery = '''
        SELECT * FROM bookings
        $whereClause
        ORDER BY created_at DESC
        LIMIT @limit OFFSET @offset
      ''';
      parameters['limit'] = limit;
      parameters['offset'] = offset;

      final dataResult = await _db.execute(
        Sql.named(dataQuery),
        parameters: parameters,
      );
      bookings = dataResult.map(_mapRowToBooking).toList();

      return PaginationResult(
        data: bookings,
        totalCount: totalCount,
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw DatabaseException('Failed to get paginated bookings: $e');
    }
  }

  @override
  Future<List<Booking>> findByStatus(String status, {int? limit, int? offset}) async {
    try {
      final limitClause = limit != null ? 'LIMIT @limit' : '';
      final offsetClause = offset != null ? 'OFFSET @offset' : '';
      final result = await _db.execute(
        Sql.named('SELECT * FROM bookings WHERE status = @status ORDER BY created_at DESC $limitClause $offsetClause'),
        parameters: {
          'status': status,
          'limit': ?limit,
          'offset': ?offset,
        },
      );
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find bookings by status: $e');
    }
  }

  @override
  Future<List<Booking>> findByDateRange(DateTime from, DateTime to, {int? limit, int? offset}) async {
    try {
      final limitClause = limit != null ? 'LIMIT @limit' : '';
      final offsetClause = offset != null ? 'OFFSET @offset' : '';
      final result = await _db.execute(
        Sql.named('''
          SELECT * FROM bookings 
          WHERE created_at >= @from AND created_at <= @to
          ORDER BY created_at DESC
          $limitClause $offsetClause
        '''),
        parameters: {
          'from': from.toUtc(),
          'to': to.toUtc(),
          'limit': ?limit,
          'offset': ?offset,
        },
      );
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find bookings by date range: $e');
    }
  }

  @override
  Future<List<Booking>> findAvailableForMechanic({int? limit, int? offset}) async {
    try {
      final limitClause = limit != null ? 'LIMIT @limit' : '';
      final offsetClause = offset != null ? 'OFFSET @offset' : '';
      final result = await _db.execute('''
        SELECT b.id, b.customer_id, b.vehicle_id, b.status, b.public_token, b.notes, b.estimated_completion_date, b.created_at, b.updated_at
        FROM bookings b
        LEFT JOIN mechanic_assignments ma ON b.id = ma.booking_id
        WHERE ma.id IS NULL AND b.status != 'DELIVERED' AND b.status != 'CANCELLED'
        ORDER BY b.created_at DESC
        $limitClause $offsetClause
      ''');
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find available bookings for mechanic: $e');
    }
  }

  @override
  Future<Booking> update(Booking booking) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          UPDATE bookings 
          SET customer_id = @customerId, vehicle_id = @vehicleId, status = @status, 
              notes = @notes, estimated_completion_date = @estimatedCompletionDate, updated_at = @updatedAt
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': booking.id,
          'customerId': booking.customerId,
          'vehicleId': booking.vehicleId,
          'status': booking.status.value,
          'notes': booking.notes,
          'estimatedCompletionDate': booking.estimatedCompletionDate,
          'updatedAt': DateTime.now().toUtc(),
        },
      );

      return _mapRowToBooking(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update booking: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.execute(
        Sql.named('DELETE FROM bookings WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete booking: $e');
    }
  }

  String _generatePublicToken() {
    return _uuid.v4().replaceAll('-', '');
  }

  Booking _mapRowToBooking(ResultRow row) {
    final data = row.toColumnMap();
    return Booking(
      id: data['id'].toString(),
      customerId: data['customer_id'].toString(),
      vehicleId: data['vehicle_id'].toString(),
      status: BookingStatus.fromString(data['status'] as String),
      publicToken: data['public_token'] as String,
      notes: data['notes'] is String ? data['notes'] as String? : null,
      createdAt: data['created_at'] is DateTime ? data['created_at'] as DateTime : DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null ? (data['updated_at'] is DateTime ? data['updated_at'] as DateTime : DateTime.parse(data['updated_at'] as String)) : null,
      estimatedCompletionDate: data['estimated_completion_date'] != null ? (data['estimated_completion_date'] is DateTime ? data['estimated_completion_date'] as DateTime : DateTime.parse(data['estimated_completion_date'] as String)) : null,
    );
  }
}
