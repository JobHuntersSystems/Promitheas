import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/selected_stores_provider.dart';
import '../models/store_offer.dart';
import '../providers/product_detail_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product detail'),
      ),
      body: asyncDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
              ? {product.bestStoreId}
              : selectedStoreIds;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productDetailProvider(productId));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
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
                              .state = {product.bestStoreId};
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
                const SizedBox(height: 24),
              ],
            ),
          );
        },
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