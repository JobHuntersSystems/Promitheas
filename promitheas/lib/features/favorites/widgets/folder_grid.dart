import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promitheas/core/router/router_names.dart';
import 'package:promitheas/core/theme/app_colors.dart';
import 'package:promitheas/features/favorites/models/favorite_folder.dart';
import 'package:promitheas/features/favorites/providers/favorites_provider.dart';
import 'package:promitheas/features/favorites/repositories/fav_folder_repository.dart';
import 'package:promitheas/features/favorites/widgets/folder_card.dart';
import 'package:promitheas/features/favorites/widgets/add_folder.dart';

/// Cuadrícula que muestra todas las carpetas de favoritos del usuario y, al final,
/// un botón integrado para crear nuevas carpetas.
class FoldersGrid extends ConsumerWidget {
  const FoldersGrid({
    super.key,
    required this.folders,
  });

  final List<FavoriteFolder> folders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: folders.length + 1,
        itemBuilder: (context, index) {
          if (index < folders.length) {
            final folder = folders[index];
            return FolderCard(
              folder: folder,
              // Asigna un color de forma cíclica. 
              // El operador módulo (%) asegura que si hay más carpetas que colores en la paleta,
              // simplemente volverá a empezar desde el primer color sin dar error de "Index Out Of Bounds".
              color: AppColors.folderPalette[index % AppColors.folderPalette.length],
              onTap: () => context.go(RouteNames.folderDetailPath(folder.folderId, folder.folderName)),
              onLongPress: () => _confirmDelete(context, ref, folder),
            );
          }
          return const AddFolderCard();
        },
      ),
    );
  }
/// Muestra un modal de alerta para evitar que el usuario borre una carpeta por accidente.
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, FavoriteFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete folder'),
        content: Text(
          'It will be removed "${folder.folderName}". The products will be without a folder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(favFolderRepositoryProvider).deleteFolder(folder.folderId);
      ref.invalidate(foldersProvider);
    }
  }
}
/// Estado de carga de la cuadrícula.
class FoldersGridLoading extends StatelessWidget {
  const FoldersGridLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const FolderCardShimmer(),
      ),
    );
  }
}
