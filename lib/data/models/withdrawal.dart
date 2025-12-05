/// Withdrawal model for balance withdrawal requests
class Withdrawal {
  final String id;
  final String nasabahId;
  final String nasabahName;
  final double amount;
  final DateTime createdAt;
  final String status; // 'pending', 'terverifikasi', 'dibatalkan'
  final String method; // 'cash', 'saldo'
  final String? proofImageUrl;
  final String? notes;
  final String? rejectionReason;
  final DateTime? processedAt;

  Withdrawal({
    required this.id,
    required this.nasabahId,
    required this.nasabahName,
    required this.amount,
    required this.createdAt,
    required this.status,
    required this.method,
    this.proofImageUrl,
    this.notes,
    this.rejectionReason,
    this.processedAt,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'] as String,
      nasabahId: json['nasabahId'] as String,
      nasabahName: json['nasabahName'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      method: json['method'] as String,
      proofImageUrl: json['proofImageUrl'] as String?,
      notes: json['notes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nasabahId': nasabahId,
      'nasabahName': nasabahName,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'method': method,
      'proofImageUrl': proofImageUrl,
      'notes': notes,
      'rejectionReason': rejectionReason,
      'processedAt': processedAt?.toIso8601String(),
    };
  }
}
