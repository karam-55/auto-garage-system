// ignore: constant_identifier_names
enum BookingStatus {
  // ignore: constant_identifier_names
  PENDING('PENDING'),
  // ignore: constant_identifier_names
  IN_PROGRESS('IN_PROGRESS'),
  // ignore: constant_identifier_names
  WAITING_PARTS('WAITING_PARTS'),
  // ignore: constant_identifier_names
  READY('READY'),
  // ignore: constant_identifier_names
  DELIVERED('DELIVERED'),
  // ignore: constant_identifier_names
  CANCELLED('CANCELLED');

  final String value;
  const BookingStatus(this.value);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid booking status: $value'),
    );
  }
}
