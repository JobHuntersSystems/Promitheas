import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Llaves maestras para controlar qué parte de la pantalla se actualiza
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation:
      '/home', // Arrancamos en Home para que veas la barra inferior (luego cambiaremos a /splash)
  routes: [
    // Rutas sin barra inferior (Pantallas completas)
    GoRoute(
      path: '/splash',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Splash Screen'))),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Login'))),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Create User'))),
    ),

    // Ruta con barra inferior (El menú principal con tus 5 pestañas)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // Envolvemos el contenido en nuestro menú personalizado
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // 0. Ubicación (Icono del Pin)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/location',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Ubicación'))),
            ),
          ],
        ),
        // 1. Búsqueda (Icono Lupa)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Búsqueda'))),
            ),
          ],
        ),
        // 2. Home (Icono Casa - Pestaña central)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Home - Gráficas'))),
              // Sub-ruta para el detalle del producto (pantalla completa, oculta la barra)
              routes: [
                GoRoute(
                  path: 'product/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id'];
                    return Scaffold(
                      body: Center(child: Text('Detalle del producto: $id')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // 3. Favoritos (Icono Bookmark)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Favoritos'))),
            ),
          ],
        ),
        // 4. Perfil (Icono Usuario)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Perfil'))),
            ),
          ],
        ),
      ],
    ),
  ],
);

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
        // Leemos los colores que definimos en el AppTheme (el gris y el naranja)
        selectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.unselectedItemColor,
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    // Al tocar un icono, le decimos a GoRouter que cambie de "rama"
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
