import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/favorite_button.dart';
import '../providers/physical_store_provider.dart';
import '../providers/product_detail_provider.dart';
import '../providers/selected_stores_provider.dart';
import '../widgets/physical_store_map_card.dart';
import '../widgets/price_history_chart.dart';
import '../widgets/product_hero_card.dart';
import '../widgets/store_offer_list.dart';
import '../widgets/store_selector.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(productDetailProvider(productId));
    final selectedStoreIds = ref.watch(selectedStoreIdsProvider(productId));
    final physicalStoresAsync = ref.watch(physicalStoresProvider(productId));

    return Scaffold(
      body: SafeArea(
        child: asyncDetail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudo cargar el detalle.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (product) {
            final effectiveSelected = selectedStoreIds.isEmpty
                ? <int>{product.bestStoreId}
                : selectedStoreIds;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(productDetailProvider(productId));
                ref.invalidate(physicalStoresProvider(productId));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _TopBar(productId: productId),
                  const SizedBox(height: 16),

                  ProductHeroCard(product: product),
                  const SizedBox(height: 18),

                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price history',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        StoreSelector(
                          offers: product.storeOffers,
                          selectedStoreIds: effectiveSelected,
                          onToggleStore: (storeId) {
                            final notifier = ref.read(
                              selectedStoreIdsProvider(productId).notifier,
                            );

                            final current = <int>{...effectiveSelected};

                            if (current.contains(storeId)) {
                              current.remove(storeId);
                            } else {
                              current.add(storeId);
                            }

                            if (current.isEmpty) {
                              current.add(product.bestStoreId);
                            }

                            notifier.state = current;
                          },
                          onSelectAll: () {
                            ref
                                .read(selectedStoreIdsProvider(productId).notifier)
                                .state = product.storeOffers
                                    .map((e) => e.storeId)
                                    .toSet();
                          },
                          onResetToBest: () {
                            ref
                                .read(selectedStoreIdsProvider(productId).notifier)
                                .state = <int>{product.bestStoreId};
                          },
                        ),
                        const SizedBox(height: 18),
                        PriceHistoryChart(
                          offers: product.storeOffers,
                          selectedStoreIds: effectiveSelected,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available stores',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 16),
                        StoreOfferList(
                          offers: product.storeOffers,
                          bestStoreId: product.bestStoreId,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  physicalStoresAsync.when(
                    loading: () => const _SimpleLoadingCard(
                      title: 'Physical stores',
                    ),
                    error: (error, _) => _SimpleMessageCard(
                      title: 'Physical stores',
                      message: 'No se pudo cargar el mapa.\n$error',
                    ),
                    data: (locations) => PhysicalStoreMapCard(
                      locations: locations,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FavoriteButton(
            productId: productId,
            iconSize: 22,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _SimpleLoadingCard extends StatelessWidget {
  const _SimpleLoadingCard({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _SimpleMessageCard extends StatelessWidget {
  const _SimpleMessageCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}