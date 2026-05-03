import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_detail.dart';
import '../repositories/product_detail_repository.dart';

final productDetailProvider =
    FutureProvider.family<ProductDetail, int>((ref, productId) async {
  final repository = ref.read(productDetailRepositoryProvider);
  return repository.getProductDetail(productId);
});