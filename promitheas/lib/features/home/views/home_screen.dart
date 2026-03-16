import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router_names.dart';
// Asegúrate de que esta ruta al widget compartido sea correcta en tu proyecto
import '../../../../shared/widgets/product_card.dart';
import '../models/product.dart'; // Tu modelo unificado
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
              const SliverToBoxAdapter(child: _HomeHeader()),

              // ── TOP RATED PRODUCTS ────────────────────────
              SliverToBoxAdapter(
                child: topRatedAsync.when(
                  loading: () => const _ProductSectionLoading(
                    title: 'TOP RATED PRODUCTS:',
                  ),
                  error: (err, stack) => const _EmptySection(),
                  data: (products) => _ProductSection(
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
                      const _ProductSectionLoading(title: 'BEST PRICES:'),
                  error: (err, stack) => const _EmptySection(),
                  data: (products) => _ProductSection(
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
                  loading: () => const _ProductSectionLoading(
                    title: "MAY BE YOU'RE LOOKING AT...",
                  ),
                  error: (err, stack) => const _EmptySection(),
                  data: (products) => _ProductSection(
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

// ── WIDGETS PRIVADOS ADAPTADOS ─────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFE8651A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'PROMITHEAS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección cuando ya tenemos los datos
class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.products,
    required this.onProductTap,
  });

  final String title;
  final List<Product> products;
  final ValueChanged<String> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const _EmptySection();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        SizedBox(
          height: 190,
          child: _ProductRow(products: products, onTap: onProductTap),
        ),
      ],
    );
  }
}

/// Sección especial solo para mostrar el skeleton loader
class _ProductSectionLoading extends StatelessWidget {
  const _ProductSectionLoading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        SizedBox(height: 190, child: _ShimmerRow()),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8E8E93),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.products, required this.onTap});
  final List<Product> products;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, index) => ProductCard(
        product: products[index],
        onTap: () => onTap(products[index].id),
      ),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      // Asegúrate de tener este widget definido en tu proyecto
      itemBuilder: (_, __) => const ProductCardShimmer(),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 190,
      child: Center(
        child: Text(
          'No products available',
          style: TextStyle(color: Color(0xFFC7C7CC)),
        ),
      ),
    );
  }
}
