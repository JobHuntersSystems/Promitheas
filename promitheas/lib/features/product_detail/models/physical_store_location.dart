class PhysicalStoreLocation {
  const PhysicalStoreLocation({
    required this.storeId,
    required this.storeName,
    this.storeLogoUrl = '',
    required this.locationId,
    this.address = '',
    this.city = '',
    this.province = '',
    this.postalCode = '',
    this.countryCode = '',
    required this.latitude,
    required this.longitude,
    this.phone = '',
    this.rating,
    this.ratingCount,
    this.schedule,
  });

  static const String _storageBaseUrl =
      'https://bocattobgdurtfxniofx.supabase.co/storage/v1/object/public/';

  final int storeId;
  final String storeName;
  final String storeLogoUrl;
  final int locationId;
  final String address;
  final String city;
  final String province;
  final String postalCode;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String phone;
  final double? rating;
  final int? ratingCount;
  final Map<String, dynamic>? schedule;

  static int _parseInt(dynamic value, {int fallback = -1}) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
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

  static String _buildPublicUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$_storageBaseUrl$path';
  }

  String get subtitle {
    final parts = [
      if (address.trim().isNotEmpty) address,
      if (city.trim().isNotEmpty) city,
      if (province.trim().isNotEmpty) province,
    ];
    return parts.join(', ');
  }

  factory PhysicalStoreLocation.fromJson(Map<String, dynamic> json) {
    return PhysicalStoreLocation(
      storeId: _parseInt(json['store_id']),
      storeName: json['store_name'] as String? ?? '',
      storeLogoUrl: _buildPublicUrl(json['store_logo'] as String?),
      locationId: _parseInt(json['location_id']),
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      province: json['province'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      phone: json['phone'] as String? ?? '',
      rating: _parseNullableDouble(json['rating']),
      ratingCount: json['rating_count'] == null
          ? null
          : _parseInt(json['rating_count']),
      schedule: json['schedule'] as Map<String, dynamic>?,
    );
  }
}