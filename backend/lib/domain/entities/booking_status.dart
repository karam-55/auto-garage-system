enum BookingStatus {
  PENDING('PENDING'),
  IN_PROGRESS('IN_PROGRESS'),
  WAITING_PARTS('WAITING_PARTS'),
  READY('READY'),
  DELIVERED('DELIVERED'),
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
