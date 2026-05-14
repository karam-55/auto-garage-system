import 'package:postgres/postgres.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../database/database_connection.dart';

class AlertRepositoryImpl implements AlertRepository {
  final DatabaseConnection _db;

  AlertRepositoryImpl(this._db);

  @override
  Future<List<Alert>> findAll() async {
    final result = await _db.execute('''
      SELECT * FROM alerts
      ORDER BY created_at DESC
    ''');

    return result.map((row) {
      final data = row.toColumnMap();
      return Alert(
        id: data['id'] as String,
        type: AlertType.fromString(data['type'] as String),
        relatedId: data['related_id'] as String?,
        message: data['message'] as String,
        isRead: data['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<List<Alert>> findUnread() async {
    final result = await _db.execute('''
      SELECT * FROM alerts
      WHERE is_read = false
      ORDER BY created_at DESC
    ''');

    return result.map((row) {
      final data = row.toColumnMap();
      return Alert(
        id: data['id'] as String,
        type: AlertType.fromString(data['type'] as String),
        relatedId: data['related_id'] as String?,
        message: data['message'] as String,
        isRead: data['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<Alert> create(Alert alert) async {
    final result = await _db.execute(
      Sql.named('''
        INSERT INTO alerts (id, type, related_id, message, is_read, created_at)
        VALUES (@id, @type, @relatedId, @message, @isRead, @createdAt)
        RETURNING *
      '''),
      parameters: {
        'id': alert.id,
        'type': alert.type.toStringValue(),
        'relatedId': alert.relatedId,
        'message': alert.message,
        'isRead': alert.isRead,
        'createdAt': alert.createdAt,
      },
    );

    final data = result.first.toColumnMap();
    return Alert(
      id: data['id'] as String,
      type: AlertType.fromString(data['type'] as String),
      relatedId: data['related_id'] as String?,
      message: data['message'] as String,
      isRead: data['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    await _db.execute(
      Sql.named('UPDATE alerts SET is_read = true WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<void> delete(String id) async {
    await _db.execute(
      Sql.named('DELETE FROM alerts WHERE id = @id'),
      parameters: {'id': id},
    );
  }
}
