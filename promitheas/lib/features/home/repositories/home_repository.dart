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

  Future<List<ProductSummary>> getPopularProducts({int limit = 5}) async {
    final response = await _supabase
        .from('popular_product_cards_v')
        .select()
        .limit(limit);

    return _mapProducts(response);
  }

  Future<List<ProductSummary>> getBestPriceProducts({int limit = 5}) async {
    final response = await _supabase
        .from('best_price_products_v')
        .select()
        .limit(limit);

    return _mapProducts(response);
  }

  Future<List<ProductSummary>> getDiscoveryProducts({int limit = 4}) async {
    final response = await _supabase
        .from('discovery_products_v')
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
