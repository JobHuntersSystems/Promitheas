import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/core/supabase/supabase_client.dart';
import 'package:promitheas/features/favorites/models/favorite_product.dart';

final favProductRepositoryProvider = Provider<FavProductRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return FavProductRepository(supabase);
});

class FavProductRepository {
  final SupabaseClient _supabase;

  FavProductRepository(this._supabase);
  String get _userId => _supabase.auth.currentUser!.id;

  Future<List<FavoriteProduct>> getProductsByFolder(int folderId) async {
    final data = await _supabase
        .from('favorite_products')
        .select('favorite_id, user_id, product_id, created_at, folder_id, products(*)')
        .eq('user_id', _userId)
        .eq('folder_id', folderId);

    return (data as List).map((e) => FavoriteProduct.fromJson(e)).toList();
  }

  Future<void> addFavorite(int productId, {int? folderId}) async {
    await _supabase.from('favorite_products').insert({
      'user_id': _userId,
      'product_id': productId,
      if (folderId != null) 'folder_id': folderId,
    });
  }

  Future<void> removeFavorite(int favoriteId) async {
    await _supabase
        .from('favorite_products')
        .delete()
        .eq('favorite_id', favoriteId);
  }

  Future<void> moveToFolder(int favoriteId, int? folderId) async {
    await _supabase
        .from('favorite_products')
        .update({'folder_id': folderId})
        .eq('favorite_id', favoriteId);
  }
}
