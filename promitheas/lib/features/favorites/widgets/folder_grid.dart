import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promitheas/core/router/router_names.dart';
import 'package:promitheas/features/favorites/models/favorite_folder.dart';
import 'package:promitheas/features/favorites/providers/favorites_provider.dart';
import 'package:promitheas/features/favorites/repositories/fav_folder_repository.dart';
import 'package:promitheas/features/favorites/widgets/folder_card.dart';
import 'package:promitheas/features/favorites/widgets/add_folder.dart'; 

class FoldersGrid extends ConsumerWidget {
  const FoldersGrid({
    super.key,
    required this.folders,
  });

  final List<FavoriteFolder> folders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: folders.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return const AddFolderCard();
          final folder = folders[index - 1];
          return FolderCard(
            folder: folder,
            onTap: () => context.go(RouteNames.folderDetailPath(folder.folderId, folder.folderName)),
            onLongPress: () => _confirmDelete(context, ref, folder),
          );
        },
      ),
    );
  }

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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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

class FoldersGridLoading extends StatelessWidget {
  const FoldersGridLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => const FolderCardShimmer(),
      ),
    );
  }
}