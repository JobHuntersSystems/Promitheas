import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:promitheas/features/home/models/product.dart';

/// Tarjeta de producto reutilizable.
/// Usada en Home (carruseles) y en Search (grid).
///
/// Uso:
/// ProductCard(product: product, onTap: () => context.go(...))
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.width = 160,
  });

  final Product product;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5EA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen ─────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: const Color(0xFFE5E5EA),
                  highlightColor: const Color(0xFFF2F2F7),
                  child: Container(height: 120, color: const Color(0xFFE5E5EA)),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 120,
                  color: const Color(0xFFF2F2F7),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFFC7C7CC),
                  ),
                ),
              ),
            ),
            // ── Nombre y precio ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.lowestPrice.toStringAsFixed(2)} EUR',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton de ProductCard — se muestra mientras carga la sección
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key, this.width = 160});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E5EA),
      highlightColor: const Color(0xFFF2F2F7),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen placeholder
            Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E5EA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            // Texto placeholder
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    color: Colors.white,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 4),
                  Container(height: 10, color: Colors.white, width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
