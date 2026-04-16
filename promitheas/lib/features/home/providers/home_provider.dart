import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product_summary.dart';
import '../repositories/home_repository.dart';

final popularProductsProvider = FutureProvider<List<ProductSummary>>((
  ref,
) async {
  final repository = ref.read(homeRepositoryProvider);
  return repository.getPopularProducts();
});

final bestPriceProductsProvider = FutureProvider<List<ProductSummary>>((
  ref,
) async {
  final repository = ref.read(homeRepositoryProvider);
  return repository.getBestPriceProducts();
});

final discoveryProductsProvider = FutureProvider<List<ProductSummary>>((
  ref,
) async {
  final repository = ref.read(homeRepositoryProvider);
  return repository.getDiscoveryProducts();
});
