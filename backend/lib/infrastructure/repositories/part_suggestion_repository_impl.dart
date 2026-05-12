import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/part_suggestion.dart';
import '../../domain/entities/part_suggestion_status.dart';
import '../../domain/entities/part_type.dart';
import '../../domain/repositories/part_suggestion_repository.dart';
import '../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class PartSuggestionRepositoryImpl implements PartSuggestionRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  PartSuggestionRepositoryImpl(this._db);

  @override
  Future<PartSuggestion> create(PartSuggestion suggestion) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('''
          INSERT INTO part_suggestions (id, booking_id, mechanic_user_id, type, description, price_syp, status, created_at)
          VALUES (@id, @bookingId, @mechanicUserId, @type, @description, @priceSyp, @status, @createdAt)
          RETURNING *
        '''),
        parameters: {
          'id': suggestion.id.isEmpty ? _uuid.v4() : suggestion.id,
          'bookingId': suggestion.bookingId,
          'mechanicUserId': suggestion.mechanicUserId,
          'type': suggestion.type.value,
          'description': suggestion.description,
          'priceSyp': suggestion.priceSYP,
          'status': suggestion.status.value,
          'createdAt': suggestion.createdAt,
          'updatedAt': suggestion.updatedAt,
        },
      );

      return _mapRowToPartSuggestion(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create part suggestion: $e');
    }
  }

  @override
  Future<PartSuggestion?> findById(String id) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM part_suggestions WHERE id = @id'),
        parameters: {'id': id},
      );

      if (result.isEmpty) return null;
      return _mapRowToPartSuggestion(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find part suggestion by id: $e');
    }
  }

  @override
  Future<List<PartSuggestion>> findByBookingId(String bookingId) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM part_suggestions WHERE booking_id = @bookingId ORDER BY created_at DESC'),
        parameters: {'bookingId': bookingId},
      );
      return result.map(_mapRowToPartSuggestion).toList();
    } catch (e) {
      throw DatabaseException('Failed to find part suggestions by booking id: $e');
    }
  }

  @override
  Future<List<PartSuggestion>> findByMechanicUserId(String mechanicUserId) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM part_suggestions WHERE mechanic_user_id = @mechanicUserId ORDER BY created_at DESC'),
        parameters: {'mechanicUserId': mechanicUserId},
      );
      return result.map(_mapRowToPartSuggestion).toList();
    } catch (e) {
      throw DatabaseException('Failed to find part suggestions by mechanic user id: $e');
    }
  }

  @override
  Future<List<PartSuggestion>> findByStatus(String status) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM part_suggestions WHERE status = @status ORDER BY created_at DESC'),
        parameters: {'status': status},
      );
      return result.map(_mapRowToPartSuggestion).toList();
    } catch (e) {
      throw DatabaseException('Failed to find part suggestions by status: $e');
    }
  }

  @override
  Future<PartSuggestion> update(PartSuggestion suggestion) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('''
          UPDATE part_suggestions 
          SET type = @type, description = @description, price_syp = @priceSyp, status = @status, updated_at = @updatedAt
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': suggestion.id,
          'type': suggestion.type.value,
          'description': suggestion.description,
          'priceSyp': suggestion.priceSYP,
          'status': suggestion.status.value,
          'updatedAt': DateTime.now().toUtc(),
        },
      );

      return _mapRowToPartSuggestion(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update part suggestion: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.execute(
        Sql.named('DELETE FROM part_suggestions WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete part suggestion: $e');
    }
  }

  PartSuggestion _mapRowToPartSuggestion(ResultRow row) {
    final data = row.toColumnMap();
    return PartSuggestion(
      id: data['id'].toString(),
      bookingId: data['booking_id'].toString(),
      mechanicUserId: data['mechanic_user_id'].toString(),
      type: PartType.fromString(data['type'] as String),
      description: data['description'] as String,
      priceSYP: data['price_syp'] != null ? (data['price_syp'] as num).toDouble() : null,
      status: PartSuggestionStatus.fromString(data['status'] as String),
      createdAt: data['created_at'] as DateTime,
      updatedAt: data['updated_at'] as DateTime?,
    );
  }

  PartType _stringToPartType(String value) {
    return PartType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid part type: $value'),
    );
  }
}
