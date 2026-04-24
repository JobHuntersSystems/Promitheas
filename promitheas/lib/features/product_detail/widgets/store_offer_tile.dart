import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/store_offer.dart';

class StoreOfferTile extends StatelessWidget {
  const StoreOfferTile({
    super.key,
    required this.offer,
    required this.isBestPrice,
  });

  final StoreOffer offer;
  final bool isBestPrice;

  Future<void> _openStore() async {
    final uri = Uri.tryParse(offer.productUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  final background = isBestPrice
      ? theme.colorScheme.primary.withValues(alpha: 0.14)
      : theme.colorScheme.surface;

  return Container(
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isBestPrice
            ? theme.colorScheme.primary.withValues(alpha: 0.35)
            : theme.dividerColor.withValues(alpha: 0.14),
      ),
    ),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 52,
                height: 52,
                color: theme.colorScheme.surface,
                child: offer.storeLogoUrl.isEmpty
                    ? const Icon(Icons.storefront_outlined)
                    : CachedNetworkImage(
                        imageUrl: offer.storeLogoUrl,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.inStock ? 'Available' : 'Out of stock',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: offer.inStock
                          ? Colors.green
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${offer.currentPrice.toStringAsFixed(2)} €',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (offer.hasDiscount) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${offer.previousPrice!.toStringAsFixed(2)} €',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        decoration: TextDecoration.lineThrough,
                        decorationColor:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            SizedBox(
              height: 40,
              child: FilledButton(
                onPressed: offer.productUrl.isEmpty ? null : _openStore,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  'Go to store',
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}