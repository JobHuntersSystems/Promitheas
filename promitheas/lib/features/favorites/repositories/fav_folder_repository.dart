import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/core/supabase/supabase_client.dart';
import 'package:promitheas/features/favorites/models/favorite_folder.dart';

final favFolderRepositoryProvider = Provider<FavFolderRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return FavFolderRepository(supabase);
});

class FavFolderRepository {
  final SupabaseClient _supabase;

  FavFolderRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  Future<List<FavoriteFolder>> getFolders() async {
    final data = await _supabase
        .from('favorite_folders')
        .select('folder_id, user_id, folder_name, created_at, favorite_products(count)')
        .eq('user_id', _userId)
        .order('created_at');

    return (data as List).map((e) => FavoriteFolder.fromJson(e)).toList();
  }

  Future<void> createFolder(String folderName) async {
    await _supabase.from('favorite_folders').insert({
      'user_id': _userId,
      'folder_name': folderName.trim(),
    });
  }

  Future<void> deleteFolder(int folderId) async {
    await _supabase
        .from('favorite_folders')
        .delete()
        .eq('folder_id', folderId);
  }
}
