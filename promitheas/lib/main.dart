import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';


void main() async {
  // Aseguramos que los bindings de Flutter estén listos antes de código asíncrono
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // await dotenv.load(fileName: ".env");
  // final supabaseUrl = dotenv.env['SUPABASE_URL'];
  // final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  // if (supabaseUrl == null || supabaseAnonKey == null) {
  //   throw Exception('Supabase credentials not found in .env file.');
  // }
  // // Inicializamos la conexión con supabase
  // await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: PromitheasApp()));
}

class PromitheasApp extends ConsumerWidget {
  const PromitheasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Promitheas',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentThemeMode,
    );
  }
}
