import 'user.dart';

/// Nasabah model - extends User
class Nasabah extends User {
  final String fullName;
  final String address;
  final double latitude;
  final double longitude;
  final double balance;
  final double withdrawableBalance;

  Nasabah({
    required super.id,
    required super.username,
    required super.phone,
    required super.email,
    required super.password,
    super.avatarUrl,
    required this.fullName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.balance,
    required this.withdrawableBalance,
  }) : super(role: 'nasabah');

  factory Nasabah.fromJson(Map<String, dynamic> json) {
    return Nasabah(
      id: json['id'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      fullName: json['fullName'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      withdrawableBalance: (json['withdrawableBalance'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'fullName': fullName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'balance': balance,
      'withdrawableBalance': withdrawableBalance,
    });
    return json;
  }
}
