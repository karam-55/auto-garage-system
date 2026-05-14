import '../entities/alert.dart';

abstract class AlertRepository {
  Future<List<Alert>> findAll();
  Future<List<Alert>> findUnread();
  Future<Alert> create(Alert alert);
  Future<void> markAsRead(String id);
  Future<void> delete(String id);
}
