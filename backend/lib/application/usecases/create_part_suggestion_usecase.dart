import '../../domain/entities/part_suggestion.dart';
import '../../domain/entities/part_suggestion_status.dart';
import '../../domain/entities/part_type.dart';
import '../../domain/repositories/part_suggestion_repository.dart';
import '../../core/errors/failures.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class CreatePartSuggestionUseCase {
  final PartSuggestionRepository _partSuggestionRepository;
  final NotificationService _notificationService;

  CreatePartSuggestionUseCase(
    this._partSuggestionRepository,
    this._notificationService,
  );

  Future<PartSuggestion> execute(
    String bookingId,
    String mechanicUserId,
    String partType,
    String description,
    double? priceSYP,
  ) async {
    try {
      final suggestion = PartSuggestion(
        id: const Uuid().v4(),
        bookingId: bookingId,
        mechanicUserId: mechanicUserId,
        type: PartType.fromString(partType),
        description: description,
        priceSYP: priceSYP,
        status: PartSuggestionStatus.PENDING_CUSTOMER_APPROVAL,
        createdAt: DateTime.now().toUtc(),
      );

      final createdSuggestion = await _partSuggestionRepository.create(suggestion);

      // Send notification
      await _notificationService.sendPartSuggestionCreated(bookingId, description);

      return createdSuggestion;
    } catch (e) {
      throw ServerFailure('Failed to create part suggestion: $e');
    }
  }
}
