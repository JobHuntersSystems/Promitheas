import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AuthRepository(supabase);
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      _supabase.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    DateTime? birthday,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': '$firstName $lastName'.trim(),
        'first_name': firstName,
        'last_name': lastName,
        
        if (phone != null && phone.isNotEmpty) 'phone_number': phone,
        if (birthday != null)
          'birthday': birthday.toIso8601String().split('T').first,
      },
    );

    if (response.user != null) {
      try {
        await _supabase.from('users').upsert({
          'user_id': response.user!.id,
          'first_name': firstName,
          'last_name': lastName,
          if (birthday != null)
            'birthday': birthday.toIso8601String().split('T').first,
        });
      } catch (e) {
        debugPrint('Error al insertar perfil tras registro: $e');
      }
    }

    return response;
  }

  Future<void> ensureUserProfile(User user) async {
    try {
      final existing = await _supabase
          .from('users')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('users').insert({
          'user_id': user.id,
          'first_name': user.userMetadata?['first_name'] ?? '',
          'last_name': user.userMetadata?['last_name'] ?? '',
          if (user.userMetadata?['birthday'] != null)
            'birthday': user.userMetadata!['birthday'],
        });
      }
    } catch (e) {
      debugPrint('Error en ensureUserProfile: $e');
    }
  }

  Future<void> signOut() => _supabase.auth.signOut();
}
