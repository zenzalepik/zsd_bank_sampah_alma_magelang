/// Base User model
class User {
  final String id;
  final String username;
  final String phone;
  final String email;
  final String password;
  final String role; // 'admin', 'driver', 'nasabah'
  final String? avatarUrl;

  User({
    required this.id,
    required this.username,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'email': email,
      'password': password,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }
}
