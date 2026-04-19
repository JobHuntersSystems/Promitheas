import 'price_point.dart';

class StoreOffer {
  const StoreOffer({
    required this.storeId,
    required this.storeName,
    this.storeLogoUrl = '',
    required this.currentPrice,
    this.previousPrice,
    this.productUrl = '',
    required this.inStock,
    this.priceHistory = const [],
  });

  static const String _storageBaseUrl =
      'https://bocattobgdurtfxniofx.supabase.co/storage/v1/object/public/';

  final int storeId;
  final String storeName;
  final String storeLogoUrl;
  final double currentPrice;
  final double? previousPrice;
  final String productUrl;
  final bool inStock;
  final List<PricePoint> priceHistory;

  bool get hasDiscount =>
      previousPrice != null && previousPrice! > currentPrice;

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

  factory StoreOffer.fromJson(
    Map<String, dynamic> json, {
    List<PricePoint> history = const [],
  }) {
    final stockStatus = (json['stock_status'] as String?) ?? 'unknown';

    return StoreOffer(
      storeId: _parseInt(json['store_id']),
      storeName: json['store_name'] as String? ?? '',
      storeLogoUrl: _buildPublicUrl(json['store_logo'] as String?),
      currentPrice: _parseDouble(json['current_price']),
      previousPrice: _parseNullableDouble(json['previous_price']),
      productUrl: json['product_url'] as String? ?? '',
      inStock: stockStatus == 'available',
      priceHistory: history,
    );
  }
}