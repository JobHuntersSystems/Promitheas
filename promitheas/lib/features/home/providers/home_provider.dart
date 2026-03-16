import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../repositories/home_repository.dart';

// 1. Provider para los productos TOP RATED
final topRatedProductsProvider = FutureProvider<List<Product>>((ref) async {
  // Leemos el repositorio inyectado
  final repository = ref.read(homeRepositoryProvider);
  // Devolvemos el Future directamente. Riverpod gestiona el loading/error.
  return repository.getTopRatedProducts();
});

// 2. Provider para los BEST PRICES (Chollos)
final bestPriceProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(homeRepositoryProvider);
  return repository.getBestPriceProducts();
});

// 3. Provider para SUGGESTED (Sugerencias)
final suggestedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(homeRepositoryProvider);
  return repository.getSuggestedProducts();
});
