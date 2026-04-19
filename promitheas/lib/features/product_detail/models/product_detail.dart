import 'store_offer.dart';

class ProductDetail {
  const ProductDetail({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.categoryName = '',
    required this.bestCurrentPrice,
    this.bestPreviousPrice,
    required this.bestStoreId,
    this.bestStoreName,
    this.storeOffers = const [],
  });

  static const String _storageBaseUrl =
      'https://bocattobgdurtfxniofx.supabase.co/storage/v1/object/public/';

  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String categoryName;
  final double bestCurrentPrice;
  final double? bestPreviousPrice;
  final int bestStoreId;
  final String? bestStoreName;
  final List<StoreOffer> storeOffers;

  bool get hasDiscount =>
      bestPreviousPrice != null && bestPreviousPrice! > bestCurrentPrice;

  static String _buildPublicUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$_storageBaseUrl$path';
  }

  static int _parseInt(dynamic value) {
    if (value == null) return -1;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? -1;
  }

  static double _parseDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory ProductDetail.fromBaseRow(
    Map<String, dynamic> json, {
    required List<StoreOffer> storeOffers,
  }) {
    final StoreOffer? cheapest = storeOffers.isEmpty
        ? null
        : ([...storeOffers]..sort(
            (a, b) => a.currentPrice.compareTo(b.currentPrice),
          )).first;

    return ProductDetail(
      id: _parseInt(json['product_id']),
      name: json['product_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: _buildPublicUrl(json['image_path'] as String?),
      categoryName: json['category_name'] as String? ?? '',
      bestCurrentPrice: cheapest?.currentPrice ?? _parseDouble(json['current_price']),
      bestPreviousPrice:
          cheapest?.previousPrice ?? _parseNullableDouble(json['previous_price']),
      bestStoreId: cheapest?.storeId ?? _parseInt(json['store_id']),
      bestStoreName: cheapest?.storeName,
      storeOffers: storeOffers,
    );
  }
}