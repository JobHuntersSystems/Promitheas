import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promitheas/features/auth/providers/auth_provider.dart';
import 'package:promitheas/features/auth/widgets/login_header.dart';
import 'package:promitheas/features/auth/widgets/loginForm.dart';
import 'package:promitheas/features/auth/widgets/createForm.dart';
import 'package:promitheas/core/router/router_names.dart';
import 'package:promitheas/core/theme/app_colors.dart';
import 'package:promitheas/shared/widgets/status_banner.dart';

/// Pantalla principal de autenticación.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    /// Controlador para alternar entre "Login" (0) y "Registro" (1).
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool get _isLogin => _tabController.index == 0;

  final _loginKey = GlobalKey<FormState>();
  final _signupKey = GlobalKey<FormState>();
/// Controladores de texto para capturar los inputs del usuario.
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime? _birthday;

  String? _errorMsg;
  bool _signupSuccess = false;

/// Inicializa los controladores y añade un "listener" (escuchador) a las pestañas.
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }
/// Se ejecuta cada vez que el usuario cambia de pestaña.
  /// Su propósito es limpiar errores viejos o mensajes de éxito para que no 
  /// aparezcan en la pestaña equivocada.
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    setState(() {
      _errorMsg = null;
      _signupSuccess = false;
    });
  }
/// Limpia la memoria
  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      helpText: 'Birthday Date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.primaryFire),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthday = picked);
  }
/// Función principal que gestiona el envío de los formularios.
  Future<void> _submit() async {
    final formKey = _isLogin ? _loginKey : _signupKey;
    if (!formKey.currentState!.validate()) return;
    setState(() {
      _errorMsg = null;
      _signupSuccess = false;
    });

    final notifier = ref.read(authFormProvider.notifier);
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    final error = _isLogin
        ? await notifier.signIn(email: email, password: pass)
        : await notifier.signUp(
            email: email,
            password: pass,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            birthday: _birthday,
          );

    if (!mounted) return;

    if (error != null) {
      setState(() => _errorMsg = error);
    } else if (_isLogin) {
      context.go(RouteNames.home);
    } else {
      setState(() => _signupSuccess = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authFormProvider).isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.backgroundDark, const Color(0xFF1E3A5F)]
                : [AppColors.primaryFire, const Color(0xFFFF9A3C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 40),
                  _buildCard(isLoading, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
/// Construye la tarjeta blanca/oscura central que contiene las pestañas y los formularios.
  Widget _buildCard(bool isLoading, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabBar(isDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isLogin
                      ? LoginForm(
                          formKey: _loginKey,
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                        )
                      : SignupForm(
                          formKey: _signupKey,
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                          confirmCtrl: _confirmCtrl,
                          firstNameCtrl: _firstNameCtrl,
                          lastNameCtrl: _lastNameCtrl,
                          phoneCtrl: _phoneCtrl,
                          birthday: _birthday,
                          onPickBirthday: _pickBirthday,
                        ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: _errorMsg != null
                      ? StatusBanner(message: _errorMsg!, isError: true)
                      : _signupSuccess
                          ? const StatusBanner(
                              message: 'Account created! Check your email to confirm.',
                              isError: false,
                            )
                          : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
                _buildSubmitButton(isLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }
/// Construye la barra de pestañas (Login / Registro).
  Widget _buildTabBar(bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryFire,
        indicatorWeight: 3,
        dividerColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08),
        labelColor: AppColors.primaryFire,
        unselectedLabelColor:
            isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black38,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        tabs: const [
          Tab(text: 'Log in'),
          Tab(text: 'Create account'),
        ],
      ),
    );
  }
/// Construye el botón principal de acción.
  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryFire,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryFire.withValues(alpha: 0.55),
          elevation: isLoading ? 0 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                _isLogin ? 'Log in' : 'Create account',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
