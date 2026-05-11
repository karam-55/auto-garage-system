enum MechanicAssignmentStatus {
  ASSIGNED('ASSIGNED'),
  IN_PROGRESS('IN_PROGRESS'),
  WAITING_PARTS('WAITING_PARTS'),
  READY('READY'),
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
