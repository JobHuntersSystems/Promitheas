import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/features/auth/repositories/auth_repository.dart';

/// Escucha los cambios de sesión de Supabase y cuando el usuario confirma el email e inicia sesión por primera vez,
/// inserta su fila en la tabla users si no existe.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

/// Gestiona el estado del formulario de autenticación (login y registro).
class AuthFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}
/// Intenta iniciar sesión con un email y contraseña existentes.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = const AsyncData(null);
      return null;
    } on AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return _mapError(e.message);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return 'Unexpected error. Try again.';
    }
  }
/// Registra un nuevo usuario en Supabase con sus datos personales.
  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    DateTime? birthday,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            birthday: birthday,
          );
      state = const AsyncData(null);
      return null;
    } on AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return _mapError(e.message);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return 'Unexpected error. Try again.';
    }
  }

  /// Cierra la sesión del usuario e invalida todos los providers de datos de usuario.
  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidateSelf();
  }

  String _mapError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Confirm your email before logging in.';
    }
    if (message.contains('User already registered')) {
      return 'An account with that email already exists.';
    }
    if (message.contains('Password should be at least')) {
      return 'The password must have at least 6 characters.';
    }
    return message;
  }
}

/// Proveedor global que expone la instancia de AuthFormNotifier.
/// La interfaz de usuario usará este proveedor para escuchar el estado de carga
final authFormProvider =
    AsyncNotifierProvider<AuthFormNotifier, void>(AuthFormNotifier.new);
