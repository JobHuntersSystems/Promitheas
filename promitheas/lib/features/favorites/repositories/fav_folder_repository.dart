import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/core/supabase/supabase_client.dart';
import 'package:promitheas/features/favorites/models/favorite_folder.dart';

/// Proveedor del repositorio de carpetas de favoritos.
final favFolderRepositoryProvider = Provider<FavFolderRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return FavFolderRepository(supabase);
});

/// Repositorio encargado de gestionar las operaciones CRUD (Crear, Leer, Actualizar, Borrar)
/// de las carpetas de favoritos de un usuario en Supabase.
class FavFolderRepository {
  final SupabaseClient _supabase;

  FavFolderRepository(this._supabase);
///helper para obtener rápidamente el ID del usuario autenticado.
  String get _userId => _supabase.auth.currentUser!.id;
/// Obtiene la lista de carpetas de favoritos del usuario actual.
  Future<List<FavoriteFolder>> getFolders() async {
    final data = await _supabase
        .from('favorite_folders')
        .select('folder_id, user_id, folder_name, created_at, favorite_products(count)')
        .eq('user_id', _userId)
        .order('created_at');

    return (data as List).map((e) => FavoriteFolder.fromJson(e)).toList();
  }
/// Crea una nueva carpeta vacía para el usuario actual.
  Future<void> createFolder(String folderName) async {
    await _supabase.from('favorite_folders').insert({
      'user_id': _userId,
      'folder_name': folderName.trim(),
    });
  }
/// Elimina una carpeta y gestiona sus productos:
  /// - Sin otras entradas → pasa a Other favorites
  /// - Ya existe en otro sitio → se borra esta entrada para evitar duplicados
  Future<void> deleteFolder(int folderId) async {
    final inFolder = await _supabase
        .from('favorite_products')
        .select('favorite_id, product_id')
        .eq('folder_id', folderId)
        .eq('user_id', _userId);

    for (final row in inFolder as List) {
      final favoriteId = row['favorite_id'] as int;
      final productId = row['product_id'] as int;

      final others = await _supabase
          .from('favorite_products')
          .select('favorite_id')
          .eq('user_id', _userId)
          .eq('product_id', productId)
          .neq('favorite_id', favoriteId);

      if ((others as List).isNotEmpty) {
        await _supabase
            .from('favorite_products')
            .delete()
            .eq('favorite_id', favoriteId);
      } else {
        await _supabase
            .from('favorite_products')
            .update({'folder_id': null})
            .eq('favorite_id', favoriteId);
      }
    }

    await _supabase
        .from('favorite_folders')
        .delete()
        .eq('folder_id', folderId);
  }
}
