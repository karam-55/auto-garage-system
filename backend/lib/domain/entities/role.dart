enum Role {
  OWNER('OWNER'),
  MANAGER('MANAGER'),
  MANAGER_SALES('MANAGER_SALES'),
  MANAGER_WAREHOUSE('MANAGER_WAREHOUSE'),
  RECEPTIONIST('RECEPTIONIST'),
  MECHANIC('MECHANIC'),
  ACCOUNTANT('ACCOUNTANT'),
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
