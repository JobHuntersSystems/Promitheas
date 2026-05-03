import 'package:promitheas/shared/models/product_summary.dart';
class FavoriteProduct {
  const FavoriteProduct({
    required this.favoriteId,
    required this.userId,
    required this.productId,
    required this.createdAt,
    this.folderId,
    this.product,
  });

  final int favoriteId;
  final String userId;
  final int productId;
  final DateTime createdAt;
  final int? folderId;
  final ProductSummary? product;

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    final productJson = json['products'] as Map<String, dynamic>?;

    ProductSummary? product;
    if (productJson != null) {
      final links = productJson['links_scraping'] as List<dynamic>? ?? [];

      Map<String, dynamic>? bestLink;
      double bestPrice = double.maxFinite;
      for (final link in links) {
        final map = link as Map<String, dynamic>;
        final price = (map['current_price'] as num?)?.toDouble() ?? double.maxFinite;
        if (price < bestPrice) {
          bestPrice = price;
          bestLink = map;
        }
      }

      final storeMap = bestLink?['stores'] as Map<String, dynamic>?;

      product = ProductSummary.fromJson({
        'product_id': productJson['product_id'],
        'product_name': productJson['product_name'],
        'image_path': productJson['image_path'],
        'current_price': bestLink?['current_price'],
        'previous_price': bestLink?['previous_price'],
        'store_name': storeMap?['store_name'],
      });
    }

    return FavoriteProduct(
      favoriteId: json['favorite_id'] as int,
      userId: json['user_id'] as String,
      productId: json['product_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      folderId: json['folder_id'] as int?,
      product: product,
    );
  }

  FavoriteProduct copyWith({
    int? favoriteId,
    String? userId,
    int? productId,
    DateTime? createdAt,
    int? folderId,
    bool clearFolderId = false,
    ProductSummary? product,
  }) {
    return FavoriteProduct(
      favoriteId: favoriteId ?? this.favoriteId,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
      product: product ?? this.product,
    );
  }
}
