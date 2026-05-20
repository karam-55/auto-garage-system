abstract class NotificationService {
  Future<void> sendBookingStatusChanged(String bookingId, String status);
  Future<void> sendPartSuggestionCreated(String bookingId, String partDescription);
  Future<void> sendPartSuggestionApproved(String bookingId);
  Future<void> sendPartSuggestionRejected(String bookingId);
  Future<void> sendVehicleReady(String bookingId);
}

class NotificationServiceImpl implements NotificationService {
  @override
  Future<void> sendBookingStatusChanged(String bookingId, String status) async {
    // Future: Implement WhatsApp Business API integration
  }

  @override
  Future<void> sendPartSuggestionCreated(String bookingId, String partDescription) async {
    // Future: Implement WhatsApp Business API integration
  }

  @override
  Future<void> sendPartSuggestionApproved(String bookingId) async {
    // Future: Implement WhatsApp Business API integration
  }

  @override
  Future<void> sendPartSuggestionRejected(String bookingId) async {
    // Future: Implement WhatsApp Business API integration
  }

  @override
  Future<void> sendVehicleReady(String bookingId) async {
    // Future: Implement WhatsApp Business API integration
  }
}
