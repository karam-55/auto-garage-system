// ignore: constant_identifier_names
enum PartType {
  // ignore: constant_identifier_names
  ORIGINAL('ORIGINAL'),
  // ignore: constant_identifier_names
  COMMERCIAL('COMMERCIAL'),
  // ignore: constant_identifier_names
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
