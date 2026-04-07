import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/product.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return HomeRepository(supabase);
});

class HomeRepository {
  final SupabaseClient _supabase;
  static const _delay = Duration(milliseconds: 700);

  HomeRepository(this._supabase);

  Future<List<Product>> getTopRatedProducts({int limit = 5}) async {
    await Future.delayed(_delay);
    return _mockProducts.toList()..sort((a, b) => b.rating.compareTo(a.rating));
  }

  Future<List<Product>> getBestPriceProducts({int limit = 5}) async {
    await Future.delayed(_delay);
    return _mockProducts.toList()
      ..sort((a, b) => a.lowestPrice.compareTo(b.lowestPrice));
  }

  Future<List<Product>> getSuggestedProducts({int limit = 4}) async {
    await Future.delayed(_delay);
    return _mockProducts.take(limit).toList();
  }

  static final _mockProducts = <Product>[
    Product(
      id: 'p1',
      name: 'iPhone 16 Pro Max',
      description: 'A18 Pro chip. Titanium design.',
      imageUrl: 'https://picsum.photos/seed/iphone16/300/300',
      lowestPrice: 1199.00,
      rating: 4.8,
      category: 'Smartphones',
      storePrices: [
        StorePrice(
          storeId: 'amazon',
          storeName: 'Amazon',
          price: 1199.00,
          productUrl: 'https://amazon.es',
          priceHistory: _generateHistory(
            basePrice: 1250,
            days: 30,
            trend: -0.003,
            seed: 1,
          ),
        ),
        StorePrice(
          storeId: 'pccomponentes',
          storeName: 'PcComponentes',
          price: 1249.00,
          productUrl: 'https://pccomponentes.com',
          priceHistory: _generateHistory(
            basePrice: 1280,
            days: 30,
            trend: -0.001,
            seed: 2,
          ),
        ),
      ],
    ),

    // ... Puedes añadir los demás productos mock aquí siguiendo el mismo patrón ...
  ];

  static List<PricePoint> _generateHistory({
    required double basePrice,
    required int days,
    double trend = 0.0,
    int seed = 1,
  }) {
    final now = DateTime.now();
    final history = <PricePoint>[];
    double price = basePrice;

    for (int i = days; i >= 0; i--) {
      final oscillation = basePrice * 0.025 * _sin(i * seed);
      final trendEffect = basePrice * trend * (days - i);
      price = (basePrice + oscillation + trendEffect).clamp(
        basePrice * 0.80,
        basePrice * 1.20,
      );
      history.add(
        PricePoint(
          date: now.subtract(Duration(days: i)),
          price: double.parse(price.toStringAsFixed(2)),
        ),
      );
    }
    return history;
  }

  static double _sin(int x) {
    const values = [
      0.0,
      0.5,
      0.87,
      1.0,
      0.87,
      0.5,
      0.0,
      -0.5,
      -0.87,
      -1.0,
      -0.87,
      -0.5,
    ];
    return values[x.abs() % values.length];
  }
}
