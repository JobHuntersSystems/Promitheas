abstract final class RouteNames {
  // Paths
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String search = '/search';
  static const String productDetail = '/product/:id';
  static const String saved = '/saved';
  static const String profile = '/profile';
  static const String userConfig = '/profile/config';
  static const String termsPrivacy = '/profile/terms';
  static const String favorites = '/favorites';

  // Named routes (para context.goNamed())
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String welcomeName = 'welcome';
  static const String homeName = 'home';
  static const String searchName = 'search';
  static const String productDetailName = 'product-detail';
  static const String savedName = 'saved';
  static const String profileName = 'profile';
  static const String favoritesName = 'favorites';

  // Helper para construir la ruta de detalle de producto
  static String productDetailPath(int id) => '$productDetail/$id';
}
