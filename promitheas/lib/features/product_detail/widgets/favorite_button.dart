import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promitheas/features/favorites/models/favorite_folder.dart';
import 'package:promitheas/features/favorites/models/favorite_product.dart';
import 'package:promitheas/features/favorites/providers/favorites_provider.dart';
import 'package:promitheas/features/favorites/repositories/fav_product_repository.dart';

// 1. Cambiamos a ConsumerStatefulWidget
class FavoriteButton extends ConsumerStatefulWidget {
  const FavoriteButton({
    super.key,
    required this.productId,
    this.iconSize = 22,
  });

  final int productId;
  final double iconSize;

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  // 2. Variable de estado local para bloquear el botón
  bool _isMutating = false;

  @override
  Widget build(BuildContext context) {
    final favoriteStateAsync = ref.watch(productFavoriteStateProvider(widget.productId));

    return favoriteStateAsync.when(
      loading: () => Icon(
        Icons.bookmark_border_rounded,
        size: widget.iconSize,
      ),
      error: (_, __) => IconButton(
        icon: Icon(Icons.bookmark_border_rounded, size: widget.iconSize),
        onPressed: null,
      ),
      data: (favoriteProduct) {
        final isFavorite = favoriteProduct != null;

        return GestureDetector(
          onLongPress: _isMutating ? null : () => _showFoldersSheet(context, ref),
          child: IconButton(
            tooltip: 'Favorites',
            icon: _isMutating
                ? SizedBox(
                    width: widget.iconSize,
                    height: widget.iconSize,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: widget.iconSize,
                  ),
            onPressed: _isMutating
                ? null
                : () async {
                    setState(() => _isMutating = true);

                    try {
                      final repository = ref.read(favProductRepositoryProvider);

                      if (isFavorite) {
                        await repository.removeFavorite(favoriteProduct.favoriteId);
                      } else {
                        await repository.addFavorite(widget.productId);
                      }

                      ref.invalidate(productFavoriteStateProvider(widget.productId));
                      ref.invalidate(freeProductsProvider);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite
                                  ? 'Removed from favorites'
                                  : 'Saved to favorites',
                            ),
                            duration: const Duration(milliseconds: 1500),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isMutating = false);
                      }
                    }
                  },
          ),
        );
      },
    );
  }

  Future<void> _showFoldersSheet(BuildContext context, WidgetRef ref) async {
    // La lógica de la carpeta se mantiene igual, recuerda usar widget.productId
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _FavoriteFoldersSheet(productId: widget.productId),
    );

    ref.invalidate(productFavoriteStateProvider(widget.productId));
    ref.invalidate(foldersProvider);
  }
}

class _FavoriteFoldersSheet extends ConsumerWidget {
  const _FavoriteFoldersSheet({
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Updated to match your favorites_provider.dart
    final foldersAsync = ref.watch(foldersProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: foldersAsync.when(
          loading: () => const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => SizedBox(
            height: 180,
            child: Center(
              child: Text('No se pudieron cargar las carpetas.\n$error'),
            ),
          ),
          data: (folders) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save product',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bookmark_add_outlined),
                  title: const Text('Save without folder'),
                  onTap: () async {
                    final repository = ref.read(favProductRepositoryProvider);
                    
                    await repository.addFavorite(
                      productId, 
                      folderId: null, // Utilizing your named parameter
                    );

                    if (context.mounted) Navigator.pop(context);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Saved to favorites'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                if (folders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('You have no folders yet.'),
                  )
                else
                  ...folders.map(
                    (folder) => _FolderTile(
                      folder: folder,
                      productId: productId,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FolderTile extends ConsumerWidget {
  const _FolderTile({
    required this.folder,
    required this.productId,
  });

  final FavoriteFolder folder;
  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.folder_outlined),
      // Updated to match the FavoriteFolder property name
      title: Text(folder.folderName), 
      onTap: () async {
        final repository = ref.read(favProductRepositoryProvider);
        
        await repository.addFavorite(
          productId,
          folderId: folder.folderId, // Updated to match the FavoriteFolder property name
        );

        if (context.mounted) Navigator.pop(context);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved to "${folder.folderName}"'),
            ),
          );
        }
      },
    );
  }
}