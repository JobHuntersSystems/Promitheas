import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promitheas/core/theme/app_colors.dart';
import 'package:promitheas/features/favorites/providers/favorites_provider.dart';
import 'package:promitheas/shared/widgets/page_header.dart';
import 'package:promitheas/shared/widgets/product_card.dart';
import 'package:promitheas/features/favorites/widgets/folder_grid.dart';
import 'package:promitheas/features/favorites/widgets/folders_empty.dart';
import 'package:go_router/go_router.dart';
import 'package:promitheas/core/router/router_names.dart';

//pantalla principal de favoritos
class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos ambos providers
    final foldersAsync = ref.watch(foldersProvider);
    final unclassifiedAsync = ref.watch(freeProductsProvider);

    return Scaffold(
      // RefreshIndicator envuelve el scroll principal para implementar la clásica
      // acción de "deslizar hacia abajo para recargar" (Pull-to-refresh).
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryFire,
          onRefresh: () async {
            ref.invalidate(foldersProvider);
            ref.invalidate(freeProductsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // --- SLIVER 1: Cabecera ---
              const SliverToBoxAdapter(
                child: PageHeader(
                  icon: Icons.bookmark_rounded,
                  title: 'FAVORITES',
                ),
              ),
              // --- SLIVER 2: Cuadrícula de Carpetas ---
              SliverToBoxAdapter(
                child: foldersAsync.when(
                  loading: () => const FoldersGridLoading(),
                  error: (err, stack) => const FoldersEmpty(),
                  data: (folders) {return FoldersGrid(folders: folders);
                  },
                ),
              ),
// --- SLIVER 3: Productos sin clasificar ---
              SliverToBoxAdapter(
                child: unclassifiedAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (products) {
                    if (products.isEmpty) return const SizedBox.shrink(); 
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                          child: Text(
                            'Other favorites',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.65, 
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index].product;
                              if (product == null) return const SizedBox.shrink();
                              
                              // Navegación limpia usando GoRouter pasando el ID del producto
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  context.go(RouteNames.productDetailPath(product.id.toString()));
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}