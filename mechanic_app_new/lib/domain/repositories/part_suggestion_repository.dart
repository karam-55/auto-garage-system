import '../entities/part_suggestion.dart';
import '../../core/error/failures.dart';

abstract class PartSuggestionRepository {
  Future<List<PartSuggestion>> getPartSuggestions(String bookingId);
  Future<PartSuggestion> createPartSuggestion(
    String bookingId,
    String mechanicUserId,
    String type,
    String description,
    double? priceSYP,
  );
}
