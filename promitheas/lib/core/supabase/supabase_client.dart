import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Este provider expone la instancia global de Supabase
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
