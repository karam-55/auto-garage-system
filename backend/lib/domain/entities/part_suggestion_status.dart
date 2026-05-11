enum PartSuggestionStatus {
  PENDING_CUSTOMER_APPROVAL('PENDING_CUSTOMER_APPROVAL'),
  APPROVED('APPROVED'),
  REJECTED('REJECTED');

  final String value;
  const PartSuggestionStatus(this.value);

  static PartSuggestionStatus fromString(String value) {
    return PartSuggestionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid part suggestion status: $value'),
    );
  }
}
