// ignore: constant_identifier_names
enum PartSuggestionStatus {
  // ignore: constant_identifier_names
  PENDING_CUSTOMER_APPROVAL('PENDING_CUSTOMER_APPROVAL'),
  // ignore: constant_identifier_names
  APPROVED('APPROVED'),
  // ignore: constant_identifier_names
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
