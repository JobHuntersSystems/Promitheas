import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/features/auth/repositories/auth_repository.dart';

/// Escucha los cambios de sesión de Supabase (login, logout, token refresh…)
/// Cuando el usuario confirma el email e inicia sesión por primera vez,
/// inserta su fila en la tabla users si no existe.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges.map((state) {
    if (state.event == AuthChangeEvent.signedIn && state.session != null) {
      ref
          .read(authRepositoryProvider)
          .ensureUserProfile(state.session!.user);
    }
    return state;
  });
});

/// Gestiona el estado del formulario: loading, error, éxito
class AuthFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

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
      return 'Error inesperado. Inténtalo de nuevo.';
    }
  }

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
      return 'Error inesperado. Inténtalo de nuevo.';
    }
  }

  String _mapError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión.';
    }
    if (message.contains('User already registered')) {
      return 'Ya existe una cuenta con ese correo.';
    }
    if (message.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return message;
  }
}

final authFormProvider =
    AsyncNotifierProvider<AuthFormNotifier, void>(AuthFormNotifier.new);
