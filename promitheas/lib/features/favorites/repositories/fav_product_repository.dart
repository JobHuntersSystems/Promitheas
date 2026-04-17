import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/core/supabase/supabase_client.dart';
import 'package:promitheas/features/favorites/models/favorite_product.dart';

final favProductRepositoryProvider = Provider<FavProductRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return FavProductRepository(supabase);
});

/// Repositorio encargado de gestionar las operaciones CRUD de los productos favoritos
class FavProductRepository {
  final SupabaseClient _supabase;

  FavProductRepository(this._supabase);
  String get _userId => _supabase.auth.currentUser!.id;
/// Constante privada que define qué columnas queremos obtener de la base de datos.
  static const _productSelect =
      'favorite_id, user_id, product_id, created_at, folder_id, products(product_id, product_name, description, image_path)';
/// Obtiene todos los productos favoritos que están dentro de una carpeta específica.
  Future<List<FavoriteProduct>> getProductsByFolder(int folderId) async {
    final data = await _supabase
        .from('favorite_products')
        .select(_productSelect)
        .eq('user_id', _userId)
        .eq('folder_id', folderId);

    return (data as List).map((e) => FavoriteProduct.fromJson(e)).toList();
  }
/// Añade un nuevo producto a la lista de favoritos.
  Future<void> addFavorite(int productId, {int? folderId}) async {
    await _supabase.from('favorite_products').insert({
      'user_id': _userId,
      'product_id': productId,
      if (folderId != null) 'folder_id': folderId,
    });
  }
/// Elimina un producto de la lista de favoritos.
  Future<void> removeFavorite(int favoriteId) async {
    await _supabase
        .from('favorite_products')
        .delete()
        .eq('favorite_id', favoriteId);
  }
/// Mueve un producto favorito existente a otra carpeta.
  Future<void> moveToFolder(int favoriteId, int? folderId) async {
    await _supabase
        .from('favorite_products')
        .update({'folder_id': folderId})
        .eq('favorite_id', favoriteId);
  }
  /// Obtiene los productos favoritos "sueltos", es decir, aquellos que el usuario
  Future<List<FavoriteProduct>> getfreeProducts() async {
    final data = await _supabase
        .from('favorite_products')
        .select(_productSelect)
        .eq('user_id', _userId)
        .isFilter('folder_id', null)
        .order('created_at', ascending: false);

    return (data as List).map((e) => FavoriteProduct.fromJson(e)).toList();
  }
}
