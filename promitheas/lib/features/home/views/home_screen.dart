import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promitheas/core/router/router_names.dart';
import 'package:promitheas/features/home/widgets/home_header.dart';
import 'package:promitheas/features/home/widgets/empty_section.dart';
import 'package:promitheas/features/home/widgets/product_section_loading.dart';
import 'package:promitheas/features/home/widgets/product_section.dart';
import '../providers/home_provider.dart'; // Los 3 nuevos providers

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ya no leemos un viewmodel gigante, leemos los 3 estados independientes
    final topRatedAsync = ref.watch(topRatedProductsProvider);
    final bestPricesAsync = ref.watch(bestPriceProductsProvider);
    final suggestedAsync = ref.watch(suggestedProductsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFE8651A),
          onRefresh: () async {
            // En Riverpod, 'refresh' simplemente invalida los providers
            // y ellos se vuelven a llamar automáticamente. Magia.
            ref.invalidate(topRatedProductsProvider);
            ref.invalidate(bestPriceProductsProvider);
            ref.invalidate(suggestedProductsProvider);
          },
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: HomeHeader()),

              // ── TOP RATED PRODUCTS ────────────────────────
              SliverToBoxAdapter(
                child: topRatedAsync.when(
                  loading: () =>
                      const ProductSectionLoading(title: 'TOP RATED PRODUCTS:'),
                  error: (err, stack) => const EmptySection(),
                  data: (products) => ProductSection(
                    title: 'TOP RATED PRODUCTS:',
                    products: products,
                    onProductTap: (id) =>
                        context.go(RouteNames.productDetailPath(id)),
                  ),
                ),
              ),

              // ── BEST PRICES ───────────────────────────────
              SliverToBoxAdapter(
                child: bestPricesAsync.when(
                  loading: () =>
                      const ProductSectionLoading(title: 'BEST PRICES:'),
                  error: (err, stack) => const EmptySection(),
                  data: (products) => ProductSection(
                    title: 'BEST PRICES:',
                    products: products,
                    onProductTap: (id) =>
                        context.go(RouteNames.productDetailPath(id)),
                  ),
                ),
              ),

              // ── MAY BE YOU'RE LOOKING AT ──────────────────
              SliverToBoxAdapter(
                child: suggestedAsync.when(
                  loading: () => const ProductSectionLoading(
                    title: "MAY BE YOU'RE LOOKING AT...",
                  ),
                  error: (err, stack) => const EmptySection(),
                  data: (products) => ProductSection(
                    title: "MAY BE YOU'RE LOOKING AT...",
                    products: products,
                    onProductTap: (id) =>
                        context.go(RouteNames.productDetailPath(id)),
                  ),
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
