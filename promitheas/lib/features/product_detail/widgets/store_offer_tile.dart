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
              ? theme.colorScheme.primary.withValues(alpha: 0.25)
              : theme.dividerColor.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 54,
              height: 54,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  offer.inStock ? 'Available' : 'Out of stock',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: offer.inStock ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${offer.currentPrice.toStringAsFixed(2)} €',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (offer.hasDiscount)
                Text(
                  '${offer.previousPrice!.toStringAsFixed(2)} €',
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: offer.productUrl.isEmpty ? null : _openStore,
            child: const Text('Go to store'),
          ),
        ],
      ),
    );
  }
}