// ignore: constant_identifier_names
enum Role {
  // ignore: constant_identifier_names
  OWNER('OWNER'),
  // ignore: constant_identifier_names
  MANAGER('MANAGER'),
  // ignore: constant_identifier_names
  MANAGER_SALES('MANAGER_SALES'),
  // ignore: constant_identifier_names
  MANAGER_WAREHOUSE('MANAGER_WAREHOUSE'),
  // ignore: constant_identifier_names
  RECEPTIONIST('RECEPTIONIST'),
  // ignore: constant_identifier_names
  MECHANIC('MECHANIC'),
  // ignore: constant_identifier_names
  ACCOUNTANT('ACCOUNTANT'),
  // ignore: constant_identifier_names
  HR_MANAGER('HR_MANAGER');

  final String value;
  const Role(this.value);

  static Role fromString(String value) {
    return Role.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw ArgumentError('Invalid role: $value'),
    );
  }
}
