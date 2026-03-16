class Product {
  const Product({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    required this.lowestPrice,
    this.rating = 0.0,
    this.storePrices = const [],
    this.category = '',
    this.isSaved = false,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double lowestPrice;
  final double rating;
  final List<StorePrice> storePrices;
  final String category;
  final bool isSaved; // Estado local (UI)

  // Parseo desde Supabase
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      lowestPrice: (json['lowest_price'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
      storePrices: (json['store_prices'] as List<dynamic>? ?? [])
          .map((e) => StorePrice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Clonado para inmutabilidad manual
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? lowestPrice,
    double? rating,
    List<StorePrice>? storePrices,
    String? category,
    bool? isSaved,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      lowestPrice: lowestPrice ?? this.lowestPrice,
      rating: rating ?? this.rating,
      storePrices: storePrices ?? this.storePrices,
      category: category ?? this.category,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class StorePrice {
  const StorePrice({
    required this.storeId,
    required this.storeName,
    this.storeLogo = '',
    required this.price,
    this.productUrl = '',
    this.inStock = true,
    this.priceHistory = const [],
  });

  final String storeId;
  final String storeName;
  final String storeLogo;
  final double price;
  final String productUrl;
  final bool inStock;
  final List<PricePoint> priceHistory;

  factory StorePrice.fromJson(Map<String, dynamic> json) {
    return StorePrice(
      storeId: json['store_id'] as String,
      storeName: json['store_name'] as String,
      storeLogo: json['store_logo'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      productUrl: json['product_url'] as String? ?? '',
      inStock: json['in_stock'] as bool? ?? true,
      priceHistory: (json['price_history'] as List<dynamic>? ?? [])
          .map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PricePoint {
  const PricePoint({required this.date, required this.price});

  final DateTime date;
  final double price;

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num).toDouble(),
    );
  }
}
