import 'user.dart';

/// Driver model - extends User
class Driver extends User {
  final String fullName;
  final String vehicleNumber;
  final bool isAvailable;
  final double currentLatitude;
  final double currentLongitude;

  Driver({
    required super.id,
    required super.username,
    required super.phone,
    required super.email,
    required super.password,
    super.avatarUrl,
    required this.fullName,
    required this.vehicleNumber,
    required this.isAvailable,
    required this.currentLatitude,
    required this.currentLongitude,
  }) : super(role: 'driver');

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      fullName: json['fullName'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      isAvailable: json['isAvailable'] as bool,
      currentLatitude: (json['currentLatitude'] as num).toDouble(),
      currentLongitude: (json['currentLongitude'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'fullName': fullName,
      'vehicleNumber': vehicleNumber,
      'isAvailable': isAvailable,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
    });
    return json;
  }
}
