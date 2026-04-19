import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/product_summary.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return HomeRepository(supabase);
});

class HomeRepository {
  HomeRepository(this._supabase);

  final SupabaseClient _supabase;

  static const int defaultLimit = 6;

  static const String _popularView = 'popular_product_cards_v';
  static const String _bestPriceView = 'best_price_products_v';
  static const String _discoveryView = 'discovery_products_v';

  Future<List<ProductSummary>> getPopularProducts({
    int limit = defaultLimit,
  }) async {
    final response = await _supabase
        .from(_popularView)
        .select()
        .limit(limit);

    return _mapProducts(response);
  }

  Future<List<ProductSummary>> getBestPriceProducts({
    int limit = defaultLimit,
  }) async {
    final response = await _supabase
        .from(_bestPriceView)
        .select()
        .limit(limit);

    return _mapProducts(response);
  }

  Future<List<ProductSummary>> getDiscoveryProducts({
    int limit = defaultLimit,
  }) async {
    final response = await _supabase
        .from(_discoveryView)
        .select()
        .limit(limit);

    return _mapProducts(response);
  }

  List<ProductSummary> _mapProducts(dynamic response) {
    final data = response as List<dynamic>;

    return data
        .map((item) => ProductSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
