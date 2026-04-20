import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/price_point.dart';
import '../models/store_offer.dart';
import '../providers/chart_range_provider.dart';

class PriceHistoryChart extends ConsumerWidget {
  const PriceHistoryChart({
    super.key,
    required this.productId,
    required this.offers,
    required this.selectedStoreIds,
  });

  final int productId;
  final List<StoreOffer> offers;
  final Set<int> selectedStoreIds;

  static const List<Color> _seriesColors = [
    Color(0xFFFFC62A),
    Color(0xFFFF8A2A),
    Color(0xFF32C5FF),
    Color(0xFF4ADE80),
    Color(0xFFFF5A5F),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedOffers = offers
        .where((offer) => selectedStoreIds.contains(offer.storeId))
        .where((offer) => offer.priceHistory.isNotEmpty)
        .toList();

    if (selectedOffers.isEmpty) {
      return Container(
        height: 280,
        alignment: Alignment.center,
        child: Text(
          'No history available for the selected stores.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    final range = ref.watch(chartRangeProvider(productId));

    final filteredOffers = selectedOffers
        .map((offer) => _copyOfferWithFilteredHistory(offer, range))
        .where((offer) => offer.priceHistory.isNotEmpty)
        .toList();

    if (filteredOffers.isEmpty) {
      return Container(
        height: 280,
        alignment: Alignment.center,
        child: Text(
          'No history available in this range.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    final allPoints = filteredOffers.expand((e) => e.priceHistory).toList();
    final minPrice =
        allPoints.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final maxPrice =
        allPoints.map((e) => e.price).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 300,
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF090909),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: LineChart(
            LineChartData(
              minY: (minPrice * 0.90).clamp(0, double.infinity),
              maxY: maxPrice * 1.10,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (_) => FlLine(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 58,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toStringAsFixed(0)} €',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    interval: _bottomInterval(filteredOffers),
                    getTitlesWidget: (value, meta) {
                      final label = _buildBottomLabel(filteredOffers, value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF151515),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final offer = filteredOffers[spot.barIndex];
                      return LineTooltipItem(
                        '${offer.storeName}\n${spot.y.toStringAsFixed(2)} €',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                for (int i = 0; i < filteredOffers.length; i++) ...[
                  // Glow / fire layer
                  // Main line
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3.2,
                    color: _seriesColors[i % _seriesColors.length],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: i == 0,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _seriesColors[i % _seriesColors.length]
                              .withValues(alpha: 0.28),
                          _seriesColors[i % _seriesColors.length]
                              .withValues(alpha: 0.03),
                        ],
                      ),
                    ),
                    spots: [
                      for (int j = 0; j < filteredOffers[i].priceHistory.length; j++)
                        FlSpot(
                          j.toDouble(),
                          filteredOffers[i].priceHistory[j].price,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          children: [
            for (int i = 0; i < filteredOffers.length; i++)
              _LegendItem(
                color: _seriesColors[i % _seriesColors.length],
                label: filteredOffers[i].storeName,
              ),
          ],
        ),
      ],
    );
  }

  StoreOffer _copyOfferWithFilteredHistory(StoreOffer offer, ChartRange range) {
    final filtered = _filterByRange(offer.priceHistory, range);
    return StoreOffer(
      storeId: offer.storeId,
      storeName: offer.storeName,
      storeLogoUrl: offer.storeLogoUrl,
      currentPrice: offer.currentPrice,
      previousPrice: offer.previousPrice,
      productUrl: offer.productUrl,
      inStock: offer.inStock,
      priceHistory: filtered,
    );
  }

  List<PricePoint> _filterByRange(List<PricePoint> history, ChartRange range) {
    if (history.isEmpty || range == ChartRange.all) return history;

    final now = DateTime.now();
    DateTime minDate;

    switch (range) {
      case ChartRange.threeMonths:
        minDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case ChartRange.sixMonths:
        minDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case ChartRange.oneYear:
        minDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case ChartRange.all:
        return history;
    }

    return history.where((point) => point.date.isAfter(minDate)).toList();
  }

  double _bottomInterval(List<StoreOffer> offers) {
    final length = offers.first.priceHistory.length;
    if (length <= 4) return 1;
    if (length <= 12) return 3;
    if (length <= 30) return 6;
    return (length / 4).floorToDouble();
  }

  String _buildBottomLabel(List<StoreOffer> offers, int index) {
    final history = offers.first.priceHistory;
    if (history.isEmpty || index < 0 || index >= history.length) return '';

    final date = history[index].date;
    final month = _monthShort(date.month);
    return '$month ${date.year % 100}';
  }

  String _monthShort(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}