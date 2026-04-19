import 'package:flutter/material.dart';

import '../models/store_offer.dart';

class StoreSelector extends StatelessWidget {
  const StoreSelector({
    super.key,
    required this.offers,
    required this.selectedStoreIds,
    required this.onToggleStore,
    required this.onSelectAll,
    required this.onResetToBest,
  });

  final List<StoreOffer> offers;
  final Set<int> selectedStoreIds;
  final ValueChanged<int> onToggleStore;
  final VoidCallback onSelectAll;
  final VoidCallback onResetToBest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(
          label: const Text('All'),
          onPressed: onSelectAll,
        ),
        ActionChip(
          label: const Text('Reset'),
          onPressed: onResetToBest,
        ),
        ...offers.map((offer) {
          final selected = selectedStoreIds.contains(offer.storeId);
          return FilterChip(
            label: Text(offer.storeName),
            selected: selected,
            onSelected: (_) => onToggleStore(offer.storeId),
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.18),
            checkmarkColor: theme.colorScheme.primary,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ],
    );
  }
}