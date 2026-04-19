import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../models/price_point.dart';
import '../models/product_detail.dart';
import '../models/store_offer.dart';

final productDetailRepositoryProvider = Provider<ProductDetailRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return ProductDetailRepository(supabase);
});

class ProductDetailRepository {
  ProductDetailRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<ProductDetail> getProductDetail(int productId) async {
    final storeRows = await _supabase
        .from('product_store_offers_v')
        .select()
        .eq('product_id', productId);

    final historyRows = await _supabase
        .from('product_price_history_v')
        .select()
        .eq('product_id', productId)
        .order('date', ascending: true);

    final groupedHistory = <int, List<PricePoint>>{};
    for (final row in historyRows as List<dynamic>) {
      final map = row as Map<String, dynamic>;
      final storeId = (map['store_id'] as num).toInt();
      groupedHistory.putIfAbsent(storeId, () => []);
      groupedHistory[storeId]!.add(PricePoint.fromJson(map));
    }

    final rows = storeRows as List<dynamic>;
    if (rows.isEmpty) {
      throw Exception('No se encontró información para este producto.');
    }

    final offers = rows.map((row) {
      final map = row as Map<String, dynamic>;
      final storeId = (map['store_id'] as num).toInt();
      return StoreOffer.fromJson(
        map,
        history: groupedHistory[storeId] ?? const [],
      );
    }).toList()
      ..sort((a, b) => a.currentPrice.compareTo(b.currentPrice));

    final firstRow = rows.first as Map<String, dynamic>;
    return ProductDetail.fromBaseRow(firstRow, storeOffers: offers);
  }
}