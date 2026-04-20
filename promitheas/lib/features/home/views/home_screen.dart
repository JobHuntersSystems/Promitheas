import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:promitheas/core/router/router_names.dart';
import 'package:promitheas/features/home/widgets/empty_section.dart';
import 'package:promitheas/features/home/widgets/home_header.dart';
import 'package:promitheas/features/home/widgets/product_section.dart';
import 'package:promitheas/features/home/widgets/product_section_loading.dart';
import 'package:promitheas/shared/models/product_summary.dart';

import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(popularProductsProvider);
    final bestPricesAsync = ref.watch(bestPriceProductsProvider);
    final discoveryAsync = ref.watch(discoveryProductsProvider);

    Future<void> handleRefresh() async {
      ref.invalidate(popularProductsProvider);
      ref.invalidate(bestPriceProductsProvider);
      ref.invalidate(discoveryProductsProvider);

      await Future.wait([
        ref.read(popularProductsProvider.future),
        ref.read(bestPriceProductsProvider.future),
        ref.read(discoveryProductsProvider.future),
      ]);
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFE8651A),
          onRefresh: handleRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: HomeHeader()),

              SliverToBoxAdapter(
                child: _HomeSection(
                  title: 'POPULAR PRODUCTS',
                  asyncProducts: popularAsync,
                  onProductTap: (id) =>
                      context.go(RouteNames.productDetailPath(id.toString())),
                ),
              ),

              SliverToBoxAdapter(
                child: _HomeSection(
                  title: 'BEST PRICES',
                  asyncProducts: bestPricesAsync,
                  onProductTap: (id) =>
                      context.go(RouteNames.productDetailPath(id.toString())),
                ),
              ),

              SliverToBoxAdapter(
                child: _HomeSection(
                  title: 'DISCOVERY',
                  asyncProducts: discoveryAsync,
                  onProductTap: (id) =>
                      context.go(RouteNames.productDetailPath(id.toString())),
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

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.asyncProducts,
    required this.onProductTap,
  });

  final String title;
  final AsyncValue<List<ProductSummary>> asyncProducts;
  final ValueChanged<int> onProductTap;

  @override
  Widget build(BuildContext context) {
    return asyncProducts.when(
      loading: () => ProductSectionLoading(title: title),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (products) {
        if (products.isEmpty) return const EmptySection();
        return ProductSection(
          title: title,
          products: products,
          onProductTap: onProductTap,
        );
      },
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductSectionLoading(title: title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
          ),
        ),
      ],
    );
  }
}
