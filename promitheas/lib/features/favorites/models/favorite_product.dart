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
    final productJson = json['products'];

    return FavoriteProduct(
      favoriteId: json['favorite_id'] as int,
      userId: json['user_id'] as String,
      productId: json['product_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      folderId: json['folder_id'] as int?,
      product: productJson != null
          ? ProductSummary.fromJson(productJson as Map<String, dynamic>)
          : null,
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
