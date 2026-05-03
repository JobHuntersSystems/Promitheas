import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/core/supabase/supabase_client.dart';


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AuthRepository(supabase);
});
/// Centraliza todas las peticiones de autenticación en un solo lugar.
class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);
/// Obtiene el usuario actual de la sesión activa en el dispositivo.
  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
/// Solicita el inicio de sesión a Supabase usando correo y contraseña.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      _supabase.auth.signInWithPassword(email: email, password: password);
/// Registra un nuevo usuario en el sistema de autenticación de Supabase.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    DateTime? birthday,
  }) async {
    //  Enviamos los datos a Supabase Auth. El trigger "on_auth_user_created" de SQL se encarga de insertar 
    return await _supabase.auth.signUp(
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
  }
/// Destruye la sesión activa en Supabase y limpia el almacenamiento local.
  Future<void> signOut() => _supabase.auth.signOut();
}