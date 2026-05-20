// ignore: constant_identifier_names
enum MechanicAssignmentStatus {
  // ignore: constant_identifier_names
  ASSIGNED('ASSIGNED'),
  // ignore: constant_identifier_names
  IN_PROGRESS('IN_PROGRESS'),
  // ignore: constant_identifier_names
  WAITING_PARTS('WAITING_PARTS'),
  // ignore: constant_identifier_names
  READY('READY'),
  // ignore: constant_identifier_names
  DELIVERED('DELIVERED');

  final String value;
  const MechanicAssignmentStatus(this.value);

  static MechanicAssignmentStatus fromString(String value) {
    return MechanicAssignmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid mechanic assignment status: $value'),
    );
  }
}
