class ProductSummary {
  const ProductSummary({
    required this.id,
    required this.name,
    this.imageUrl = '',
    required this.currentPrice,
    this.previousPrice,
    this.categoryName = '',
    this.isSaved = false,
    this.storeName,
    this.storeLogoUrl,
    this.sectionTag,
  });

  final int id;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double? previousPrice;
  final String categoryName;
  final bool isSaved;

  // Opcionales, por si una card quiere enseñar la tienda “ganadora”
  final String? storeName;
  final String? storeLogoUrl;

  // Opcional, útil para demo/home: “Popular”, “Best price”, etc.
  final String? sectionTag;

  bool get hasDiscount =>
      previousPrice != null && previousPrice! > currentPrice;

  double? get discountPercent {
    if (!hasDiscount) return null;
    return ((previousPrice! - currentPrice!) / previousPrice!) * 100;
  }

  double get savingsAmount {
    if (!hasDiscount) return 0;
    return previousPrice! - currentPrice;
  }

  ProductSummary copyWith({
    int? id,
    String? name,
    String? imageUrl,
    double? currentPrice,
    double? previousPrice,
    String? categoryName,
    bool? isSaved,
    String? storeName,
    String? storeLogoUrl,
    String? sectionTag,
  }) {
    return ProductSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      categoryName: categoryName ?? this.categoryName,
      isSaved: isSaved ?? this.isSaved,
      storeName: storeName ?? this.storeName,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      sectionTag: sectionTag ?? this.sectionTag,
    );
  }

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      id: json['product_id'] as int,
      name: json['product_name'] as String? ?? '',
      imageUrl: json['image_path'] as String? ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0,
      previousPrice: (json['previous_price'] as num?)?.toDouble(),
      categoryName: json['category_name'] as String? ?? '',
      isSaved: json['is_saved'] as bool? ?? false,
      storeName: json['store_name'] as String?,
      storeLogoUrl: json['store_logo'] as String?,
      sectionTag: json['section_tag'] as String?,
    );
  }
}
