import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promitheas/features/favorites/providers/favorites_provider.dart';
import 'package:promitheas/shared/widgets/product_card.dart';

class FolderScreen extends ConsumerWidget {
  const FolderScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  final int folderId;
  final String folderName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(folderProductsProvider(folderId));

    return Scaffold(
      appBar: AppBar(title: Text(folderName)),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading products')),
        data: (favorites) {
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

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(folderProductsProvider(folderId)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final product = favorites[index].product;
                  if (product == null) return const SizedBox.shrink();
                  return ProductCard(
                    product: product,
                    onTap: () {},
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
