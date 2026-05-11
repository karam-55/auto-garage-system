enum Role {
  OWNER('OWNER'),
  MANAGER('MANAGER'),
  RECEPTIONIST('RECEPTIONIST'),
  MECHANIC('MECHANIC');

  final String value;
  const Role(this.value);

  static Role fromString(String value) {
    return Role.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw ArgumentError('Invalid role: $value'),
    );
  }
}
