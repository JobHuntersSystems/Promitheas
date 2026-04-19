import 'package:flutter/material.dart';
import 'package:promitheas/shared/models/product_summary.dart';
import 'package:promitheas/features/home/widgets/empty_section.dart';
import 'package:promitheas/shared/widgets/product_card.dart';

class ProductSection extends StatelessWidget {
  const ProductSection({
    required this.title,
    required this.products,
    required this.onProductTap,
  });

  final String title;
  final List<ProductSummary> products;
  final ValueChanged<int> onProductTap; // 👈 cambiado

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const EmptySection();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        SizedBox(
          height: 280,
          child: _ProductRow(products: products, onTap: onProductTap),
        ),
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

  final List<ProductSummary> products;
  final ValueChanged<int> onTap; // 👈 cambiado

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, index) => ProductCard(
        product: products[index],
        onTap: () => onTap(products[index].id), // ✅ ahora coincide
      ),
    );
  }
}
