import 'package:flutter_riverpod/legacy.dart';

final selectedStoreIdsProvider =
    StateProvider.family<Set<int>, int>((ref, productId) => <int>{});