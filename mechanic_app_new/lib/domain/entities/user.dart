class User {
  final String id;
  final String fullName;
  final String username;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.username,
    required this.role,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? username,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      role: role ?? this.role,
    );
  }
}
