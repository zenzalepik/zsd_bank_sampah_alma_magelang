/// Transaction item model
class TransactionItem {
  final String categoryId;
  final String categoryName;
  final double weight;
  final double pricePerKg;
  final double subtotal;

  TransactionItem({
    required this.categoryId,
    required this.categoryName,
    required this.weight,
    required this.pricePerKg,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      weight: (json['weight'] as num).toDouble(),
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'weight': weight,
      'pricePerKg': pricePerKg,
      'subtotal': subtotal,
    };
  }
}

/// Transaction model
class Transaction {
  final String id;
  final String nasabahId;
  final String nasabahName;
  final String? driverId;
  final String? driverName;
  final DateTime createdAt;
  final String status; // 'proses', 'dijemput', 'selesai', 'dibatalkan'
  final List<TransactionItem> items;
  final double totalAmount;
  final String address;
  final double latitude;
  final double longitude;
  final String? notes;

  Transaction({
    required this.id,
    required this.nasabahId,
    required this.nasabahName,
    this.driverId,
    this.driverName,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      nasabahId: json['nasabahId'] as String,
      nasabahName: json['nasabahName'] as String,
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      items: (json['items'] as List)
          .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nasabahId': nasabahId,
      'nasabahName': nasabahName,
      'driverId': driverId,
      'driverName': driverName,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
    };
  }
}
