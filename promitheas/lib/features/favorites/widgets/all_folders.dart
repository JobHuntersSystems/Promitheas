import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promitheas/core/theme/app_colors.dart';
import 'package:promitheas/features/favorites/providers/favorites_provider.dart';
import 'package:promitheas/features/favorites/repositories/fav_product_repository.dart';

/// Modal para añadir productos favoritos existentes a una carpeta específica.
class AddToFolderSheet extends ConsumerStatefulWidget {
  const AddToFolderSheet({
    super.key,
    required this.folderId,
    required this.existingProductIds,
  });

  final int folderId;
  final Set<int> existingProductIds;

  @override
  ConsumerState<AddToFolderSheet> createState() => _AddToFolderSheetState();
}

/// Almacena temporalmente los IDs de favoritos seleccionados por el usuario
class _AddToFolderSheetState extends ConsumerState<AddToFolderSheet> {
  final Set<int> _selected = {};
  bool _isLoading = false;

// Escucha el provider de productos que no tienen carpeta asignada
  @override
  Widget build(BuildContext context) {
    final allFavoritesAsync = ref.watch(freeProductsProvider);

    return allFavoritesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading favorites')),
      data: (allFavorites) {
        final seen = <int>{};
        final candidates = allFavorites.where((f) {
          if (f.product == null) return false;
          if (widget.existingProductIds.contains(f.productId)) return false;
          if (seen.contains(f.productId)) return false;
          seen.add(f.productId);
          return true;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add products',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Cuerpo: Lista de productos o mensaje de vacío
            if (candidates.isEmpty)
              const Expanded(
                child: Center(child: Text('No favorites to add')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final fav = candidates[index];
                    final product = fav.product!;
                    final isSelected = _selected.contains(fav.favoriteId);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selected.add(fav.favoriteId);
                          } else {
                            _selected.remove(fav.favoriteId);
                          }
                        });
                      },
                      title: Text(
                        product.name.length > 30
                            ? '${product.name.substring(0, 30)}...'
                            : product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                      secondary: product.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                product.imageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const SizedBox(width: 48, height: 48),
                      activeColor: AppColors.primaryFire,
                    ),
                    );
                  },
                ),
              ),
              // Botón de acción inferior
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected.isEmpty || _isLoading ? null : _addSelected,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryFire,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_selected.isEmpty
                          ? 'Add'
                          : 'Add (${_selected.length})'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
/// Procesa la lógica de mover los productos seleccionados a la carpeta.
  Future<void> _addSelected() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(favProductRepositoryProvider);
      // Ejecuta la migración de cada producto seleccionado
      for (final favoriteId in _selected) {
        await repo.moveToFolder(favoriteId, widget.folderId);
      }
      // Invalida los providers para forzar la actualización de la UI en otras pantallas
      ref.invalidate(folderProductsProvider(widget.folderId));
      ref.invalidate(foldersProvider);
      ref.invalidate(freeProductsProvider);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
