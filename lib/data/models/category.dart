/// Category model for waste types
class Category {
  final String id;
  final String name;
  final String iconUrl;
  final double pricePerKg;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.pricePerKg,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'pricePerKg': pricePerKg,
      'description': description,
    };
  }
}
