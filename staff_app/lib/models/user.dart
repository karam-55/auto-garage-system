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
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'role': role,
    };
  }
}
