import 'package:flutter/material.dart';

import '../models/store_offer.dart';

class StoreSeriesSelector extends StatelessWidget {
  const StoreSeriesSelector({
    super.key,
    required this.offers,
    required this.selectedStoreIds,
    required this.onToggleStore,
    required this.onSelectAll,
  });

  final List<StoreOffer> offers;
  final Set<int> selectedStoreIds;
  final ValueChanged<int> onToggleStore;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: offers.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            final allSelected =
                offers.isNotEmpty &&
                selectedStoreIds.length == offers.length;

            return _SelectorPill(
              label: 'All',
              selected: allSelected,
              onTap: onSelectAll,
            );
          }

          final offer = offers[index - 1];
          final isSelected = selectedStoreIds.contains(offer.storeId);

          return _SelectorPill(
            label: offer.storeName,
            selected: isSelected,
            onTap: () => onToggleStore(offer.storeId),
          );
        },
      ),
    );
  }
}

class _SelectorPill extends StatelessWidget {
  const _SelectorPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withValues(alpha: 0.25);

    final backgroundColor = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surface;

    final textColor = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.55),
                    width: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}