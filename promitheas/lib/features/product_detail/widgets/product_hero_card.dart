import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product_detail.dart';

class ProductHeroCard extends StatelessWidget {
  const ProductHeroCard({
    super.key,
    required this.product,
  });

  final ProductDetail product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final muted = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65);

    return Container(
      decoration: BoxDecoration(
        color: surface,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 120,
              height: 120,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: product.imageUrl.isEmpty
                  ? const Icon(Icons.image_not_supported_outlined)
                  : CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.categoryName,
                    style: theme.textTheme.bodyLarge?.copyWith(color: muted),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Current best price',
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.bestCurrentPrice.toStringAsFixed(2)} €',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                  if ((product.bestStoreName ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Best at ${product.bestStoreName}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}