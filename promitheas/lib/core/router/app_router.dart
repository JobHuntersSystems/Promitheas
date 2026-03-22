import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:promitheas/core/router/router_names.dart';
import 'package:promitheas/features/auth/providers/auth_provider.dart';
import 'package:promitheas/features/auth/views/login_screen.dart';
import 'package:promitheas/features/home/views/home_screen.dart';
import 'package:promitheas/features/product_detail/views/product_detail_screen.dart';

// Llaves maestras para controlar qué parte de la pantalla se actualiza
final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(Ref ref) {
    // Valor inicial sincrónico desde la sesión actual de Supabase
    _isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    // Escucha cambios futuros de autenticación
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, next) {
      final loggedIn = next.maybeWhen(
        data: (s) => s.session != null,
        orElse: () => _isLoggedIn,
      );
      if (_isLoggedIn != loggedIn) {
        _isLoggedIn = loggedIn;
        notifyListeners();
      }
    });
  }

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterNotifier(ref);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.login,
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = notifier.isLoggedIn;
      final isOnLogin = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.splash;
      if (!isLoggedIn && !isOnLogin) return RouteNames.login;
      if (isLoggedIn && isOnLogin) return RouteNames.home;
      return null;
    },
    routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Splash'))),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Create User'))),
    ),

    // Ruta con barra inferior (El menú principal con tus 4 pestañas)
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) {
        // Envolvemos el contenido en nuestro menú personalizado
        return ScaffoldWithNavBar(navigationShell: shell);
      },
      branches: [
        // 0. Home (Icono Casa - Pestaña central)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (context, state) => const HomeScreen(),
              // Sub-ruta para el detalle del producto (pantalla completa, oculta la barra)
              routes: [
                GoRoute(
                  path: RouteNames.productDetail,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return ProductDetailScreen(
                      productId: id,
                    ); // ← antes era Text(...)
                  },
                ),
              ],
            ),
          ],
        ),
        // 1. Búsqueda (Icono Lupa)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.search,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Búsqueda'))),
            ),
          ],
        ),
        // 2. Favoritos (Icono Bookmark)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.favorites,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Favoritos'))),
            ),
          ],
        ),
        // 3. Perfil (Icono Usuario)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Perfil'))),
            ),
          ],
        ),
      ],
    ),
  ],
  );
});

// --- WIDGET DEL MENÚ INFERIOR ---
// Este widget se encarga de pintar la barra y cambiar de pestaña visualmente
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.unselectedItemColor,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
