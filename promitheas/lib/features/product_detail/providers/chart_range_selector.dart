import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chart_range_provider.dart';

class ChartRangeSelector extends ConsumerWidget {
  const ChartRangeSelector({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(chartRangeProvider(productId));
    final theme = Theme.of(context);

    Widget buildChip(ChartRange range, String label) {
      final isSelected = selected == range;

      return GestureDetector(
        onTap: () {
          ref.read(chartRangeProvider(productId).notifier).state = range;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      children: [
        buildChip(ChartRange.all, 'ALL'),
        buildChip(ChartRange.threeMonths, '3MO'),
        buildChip(ChartRange.sixMonths, '6MO'),
        buildChip(ChartRange.oneYear, '1Y'),
      ],
    );
  }
}