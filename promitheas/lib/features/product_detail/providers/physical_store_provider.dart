import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/physical_store_location.dart';
import '../repositories/physical_store_repository.dart';

final physicalStoresProvider =
    FutureProvider.family<List<PhysicalStoreLocation>, int>((ref, productId) async {
  final repository = ref.read(physicalStoreRepositoryProvider);
  return repository.getPhysicalStores(productId);
});