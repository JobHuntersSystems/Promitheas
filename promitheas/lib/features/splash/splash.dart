import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promitheas/core/router/router_names.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _logoOpacity;
  late Animation<double> _logoSize; // ✅ Cambiado de Scale a Size
  late Animation<double> _textReveal;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // 1. El logo aparece
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // 2. El tamaño real del logo se encoge.
    // Empieza ocupando 120 píxeles y termina ocupando exactamente 55 píxeles.
    // Al animar los píxeles reales, la "caja invisible" desaparece.
    _logoSize = Tween<double>(begin: 120.0, end: 55.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    // 3. El espacio del texto se expande
    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    // 4. El texto se vuelve visible
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
      ),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Espera 1 segundo antes de iniciar la animación
    await Future.delayed(const Duration(seconds: 1));

    _controller.forward();

    // Inicia Supabase sin bloquear, con timeout
    final supabaseInit = _initSupabase()
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint(
              'Supabase init timeout - continuando sin inicialización',
            );
          },
        )
        .catchError((e) {
          debugPrint('Error en Supabase: $e');
        });

    // Espera la animación + inicialización, pero no se bloquea si Supabase falla
    await Future.wait([
      supabaseInit,
      Future.delayed(const Duration(milliseconds: 2600)),
    ], eagerError: false);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      final session = Supabase.instance.client.auth.currentSession;
      context.go(session != null ? RouteNames.home : RouteNames.login);
    }
  }

  Future<void> _initSupabase() async {
    // try {
    //   await dotenv.load(fileName: ".env");
    //   final supabaseUrl = dotenv.env['SUPABASE_URL'];
    //   final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    //   if (supabaseUrl != null && supabaseAnonKey != null) {
    //     await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    //   }
    // } catch (e) {
    //   debugPrint('Error inicializando Supabase: $e');
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15161C),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1º EL LOGO (Ahora con ajuste vertical)
                Transform.translate(
                  // ✅ MODIFICACIÓN: El -8 significa "8 píxeles hacia arriba".
                  // Si lo quieres más arriba, pon -12 o -15. Si te pasaste, pon -4.
                  offset: const Offset(0, -8),
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: _logoSize.value,
                      height: _logoSize.value,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // 2º EL TEXTO
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _textReveal.value,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: const Padding(
                        // ✅ Ahora estos 10 píxeles son REALES y exactos
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "PROMITHEAS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            height: 1.0,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
