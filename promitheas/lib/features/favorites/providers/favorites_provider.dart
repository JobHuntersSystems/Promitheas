import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promitheas/features/favorites/models/favorite_folder.dart';
import 'package:promitheas/features/favorites/models/favorite_product.dart';
import 'package:promitheas/features/favorites/repositories/fav_folder_repository.dart';
import 'package:promitheas/features/favorites/repositories/fav_product_repository.dart';

// Lista de carpetas
final foldersProvider = FutureProvider<List<FavoriteFolder>>((ref) {
  final repository = ref.read(favFolderRepositoryProvider);
  return repository.getFolders();
});

// Productos de la carpeta concreta
final folderProductsProvider =
    FutureProvider.family<List<FavoriteProduct>, int>((ref, folderId) {
  final repository = ref.read(favProductRepositoryProvider);
  return repository.getProductsByFolder(folderId);
});

final freeProductsProvider = FutureProvider<List<FavoriteProduct>>((ref) {
  final repository = ref.read(favProductRepositoryProvider);
  return repository.getfreeProducts();
});
