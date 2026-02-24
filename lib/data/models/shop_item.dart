class ShopItem {
  final String id;
  final String name;
  final int price;
  final String category;
  bool isPurchased;
  bool isEquipped;

  ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isPurchased = false,
    this.isEquipped = false,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      category: json['category'] as String,
      isPurchased: json['isPurchased'] as bool? ?? false,
      isEquipped: json['isEquipped'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'isPurchased': isPurchased,
      'isEquipped': isEquipped,
    };
  }

  ShopItem copyWith({
    String? id,
    String? name,
    int? price,
    String? category,
    bool? isPurchased,
    bool? isEquipped,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      isPurchased: isPurchased ?? this.isPurchased,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}
