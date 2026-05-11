enum PartType {
  ORIGINAL('ORIGINAL'),
  COMMERCIAL('COMMERCIAL'),
  USED('USED');

  final String value;
  const PartType(this.value);

  static PartType fromString(String value) {
    return PartType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid part type: $value'),
    );
  }
}
