import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promitheas/core/theme/app_colors.dart';
import 'package:promitheas/features/favorites/models/favorite_product.dart';
import 'package:promitheas/features/favorites/providers/favorites_provider.dart';
import 'package:promitheas/features/favorites/repositories/fav_product_repository.dart';
import 'package:promitheas/features/favorites/widgets/all_folders.dart';
import 'package:promitheas/shared/widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import 'package:promitheas/core/router/router_names.dart';
/// Pantalla de detalle que muestra el contenido de una carpeta de favoritos específica.
class FolderScreen extends ConsumerWidget {
  const FolderScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });
/// Recibe el ID y el nombre de la carpeta a través del constructor.
  final int folderId;
  final String folderName;

  void _showProductOptions(BuildContext context, WidgetRef ref, FavoriteProduct fav) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('Remove from folder'),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(favProductRepositoryProvider).moveToFolder(fav.favoriteId, null);
                ref.invalidate(folderProductsProvider(folderId));
                ref.invalidate(freeProductsProvider);
                ref.invalidate(foldersProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove from favorites',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(favProductRepositoryProvider).removeFavorite(fav.favoriteId);
                ref.invalidate(folderProductsProvider(folderId));
                ref.invalidate(freeProductsProvider);
                ref.invalidate(foldersProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el proveedor específico para esta carpeta.
    final productsAsync = ref.watch(folderProductsProvider(folderId));

    return Scaffold(
      // Usamos el nombre de la carpeta como título dinámico en la barra superior.
      appBar: AppBar(title: Text(folderName)),
      body: Column(
        children: [
          Expanded(
            child: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading products')),
        data: (favorites) {
          // Si la carpeta no tiene productos, mostramos un mensaje.
          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'This folder is empty',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
// --- ESTADO CON DATOS ---
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(folderProductsProvider(folderId)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  // Extraemos el objeto product que vino anidado (JOIN) desde Supabase
                  final fav = favorites[index];
                  final product = fav.product;
                  // Validación de seguridad por si el producto fue borrado de la base de datos principal
                  if (product == null) return const SizedBox.shrink();
                  return GestureDetector(
                    onLongPress: () => _showProductOptions(context, ref, fav),
                    child: ProductCard(
                      product: product,
                      onTap: () {
                        context.go(RouteNames.productDetailPath(product.id.toString()));
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 8, 24, 16 + MediaQuery.of(context).padding.bottom),
            child: ElevatedButton.icon(
              onPressed: () {
                final existingIds = productsAsync.asData?.value
                        .map((f) => f.productId)
                        .toSet() ??
                    {};
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddToFolderSheet(
                    folderId: folderId,
                    existingProductIds: existingIds,
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add products',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryFire,
                elevation: 4,
                shadowColor: Colors.black26,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
