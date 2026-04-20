import 'package:flutter_riverpod/legacy.dart';

enum ChartRange {
  all,
  threeMonths,
  sixMonths,
  oneYear,
}

final chartRangeProvider =
    StateProvider.family<ChartRange, int>((ref, productId) {
  return ChartRange.all;
});