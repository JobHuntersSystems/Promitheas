class PricePoint {
  const PricePoint({
    required this.date,
    required this.price,
  });

  final DateTime date;
  final double price;

  static double parseDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      date: DateTime.parse(json['date'] as String),
      price: parseDouble(json['price']),
    );
  }
}