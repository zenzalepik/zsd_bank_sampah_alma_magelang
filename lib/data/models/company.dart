/// Company profile model
class Company {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String logoUrl;
  final String description;
  final String operationalHours;
  final double minimumWithdrawal;

  Company({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.logoUrl,
    required this.description,
    required this.operationalHours,
    required this.minimumWithdrawal,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      logoUrl: json['logoUrl'] as String,
      description: json['description'] as String,
      operationalHours: json['operationalHours'] as String,
      minimumWithdrawal: (json['minimumWithdrawal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'logoUrl': logoUrl,
      'description': description,
      'operationalHours': operationalHours,
      'minimumWithdrawal': minimumWithdrawal,
    };
  }
}
