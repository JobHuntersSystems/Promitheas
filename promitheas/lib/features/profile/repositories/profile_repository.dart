import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/features/profile/models/profile_model.dart'; // ¡Importa tu modelo!

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  // 1. OBTENER DATOS: Ahora devuelve un ProfileModel seguro
  Future<ProfileModel> fetchUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No session found');

    final response = await _supabase
        .from('users')
        .select()
        .eq('user_id', user.id)
        .single();
        
    // Magia: Convertimos la basura de Supabase en nuestro objeto limpio
    return ProfileModel.fromJson(response); 
  }

  // 2. ACTUALIZAR DATOS: Sigue recibiendo un Map porque Supabase solo entiende Maps
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No session found');

    await _supabase
        .from('users')
        .update(updates)
        .eq('user_id', user.id);
  }
}