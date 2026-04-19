import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/store_offer.dart';

class PriceHistoryChart extends StatelessWidget {
  const PriceHistoryChart({
    super.key,
    required this.offers,
    required this.selectedStoreIds,
  });

  final List<StoreOffer> offers;
  final Set<int> selectedStoreIds;

  static const List<Color> _seriesColors = [
    Color(0xFFE8651A),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFF9333EA),
    Color(0xFFDC2626),
    Color(0xFF0891B2),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedOffers = offers
        .where((offer) => selectedStoreIds.contains(offer.storeId))
        .where((offer) => offer.priceHistory.isNotEmpty)
        .toList();

    if (selectedOffers.isEmpty) {
      return Container(
        height: 260,
        alignment: Alignment.center,
        child: Text(
          'No hay histórico disponible para las tiendas seleccionadas.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    final allPoints = selectedOffers.expand((e) => e.priceHistory).toList();
    final minPrice = allPoints.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final maxPrice = allPoints.map((e) => e.price).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (int i = 0; i < selectedOffers.length; i++)
              _LegendItem(
                color: _seriesColors[i % _seriesColors.length],
                label: selectedOffers[i].storeName,
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minY: minPrice * 0.95,
              maxY: maxPrice * 1.05,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: ((maxPrice - minPrice) / 4).clamp(1, double.infinity),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toStringAsFixed(0)}€',
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                for (int i = 0; i < selectedOffers.length; i++)
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    color: _seriesColors[i % _seriesColors.length],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: i == 0,
                      color: _seriesColors[i % _seriesColors.length]
                          .withValues(alpha: 0.18),
                    ),
                    spots: [
                      for (int j = 0; j < selectedOffers[i].priceHistory.length; j++)
                        FlSpot(
                          j.toDouble(),
                          selectedOffers[i].priceHistory[j].price,
                        ),
                    ],
                  ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.surface,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final offer = selectedOffers[spot.barIndex];
                      return LineTooltipItem(
                        '${offer.storeName}\n${spot.y.toStringAsFixed(2)} €',
                        theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}