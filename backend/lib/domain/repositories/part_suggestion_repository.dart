import '../entities/part_suggestion.dart';
import '../../core/errors/failures.dart';

abstract class PartSuggestionRepository {
  Future<PartSuggestion> create(PartSuggestion suggestion);
  Future<PartSuggestion?> findById(String id);
  Future<List<PartSuggestion>> findByBookingId(String bookingId);
  Future<List<PartSuggestion>> findByMechanicUserId(String mechanicUserId);
  Future<List<PartSuggestion>> findByStatus(String status);
  Future<PartSuggestion> update(PartSuggestion suggestion);
  Future<void> delete(String id);
}
