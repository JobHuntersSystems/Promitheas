import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/core/supabase/supabase_client.dart';
import 'package:promitheas/shared/models/product_summary.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return SearchRepository(supabase);
});

class SearchRepository {
  SearchRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<ProductSummary>> searchProducts(
    String query, {
    int limit = 60,
  }) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final pattern = _buildIlikePattern(normalizedQuery);
    final response = await _supabase
        .from('best_price_products_v')
        .select()
        .or(
          'product_name.ilike.$pattern,category_name.ilike.$pattern,store_name.ilike.$pattern',
        )
        .limit(limit);

    final data = response as List<dynamic>;
    return data
        .map((item) => ProductSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String _buildIlikePattern(String value) {
    final sanitizedValue = value.replaceAll(',', ' ').replaceAll('%', '');
    return '%$sanitizedValue%';
  }
}
