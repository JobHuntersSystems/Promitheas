import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../models/physical_store_location.dart';

final physicalStoreRepositoryProvider = Provider<PhysicalStoreRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return PhysicalStoreRepository(supabase);
});

class PhysicalStoreRepository {
  PhysicalStoreRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<PhysicalStoreLocation>> getPhysicalStores(int productId) async {
    final response = await _supabase
        .from('product_physical_stores_v')
        .select()
        .eq('product_id', productId);

    final data = response as List<dynamic>;

    return data
        .map((e) => PhysicalStoreLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}