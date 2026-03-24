import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/router/router_names.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool get _isLogin => _tabController.index == 0;

  //controls
  final _loginKey = GlobalKey<FormState>();
  final _signupKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime? _birthday;

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _errorMsg;
  bool _signupSuccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    setState(() {
      _errorMsg = null;
      _signupSuccess = false;
      _emailCtrl.clear();
      _passCtrl.clear();
      _confirmCtrl.clear();
      _firstNameCtrl.clear();
      _lastNameCtrl.clear();
      _phoneCtrl.clear();
      _birthday = null;
    });
  }

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

  //birthday
  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      helpText: 'Fecha de nacimiento',
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

  // save
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
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : '+${_phoneCtrl.text.trim()}',
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

  // Build 
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
                ? [const Color(0xFF0F172A), const Color(0xFF1E3A5F)]
                : [const Color(0xFFFF6A00), const Color(0xFFFF9A3C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Header(),
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

  Widget _buildCard(bool isLoading, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  child: _buildForm(),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: _errorMsg != null
                      ? _StatusBanner(message: _errorMsg!, isError: true)
                      : _signupSuccess
                          ? const _StatusBanner(
                              message:
                                  '¡Cuenta creada! Revisa tu correo para confirmar.',
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

  Widget _buildTabBar(bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryFire,
        indicatorWeight: 3,
        dividerColor: isDark
            ? Colors.white.withValues(alpha:0.08)
            : Colors.black.withValues(alpha:0.08),
        labelColor: AppColors.primaryFire,
        unselectedLabelColor:
            isDark ? Colors.white.withValues(alpha:0.45) : Colors.black38,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        tabs: const [
          Tab(text: 'Iniciar sesión'),
          Tab(text: 'Crear cuenta'),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final formKey = _isLogin ? _loginKey : _signupKey;
    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDeco('Correo electrónico', Icons.email_outlined),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Introduce tu correo';
              if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(v)) {
                return 'Correo no válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _passCtrl,
            label: 'Contraseña',
            obscure: _obscurePass,
            onToggle: () => setState(() => _obscurePass = !_obscurePass),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Introduce tu contraseña';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          if (!_isLogin) ...[
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmCtrl,
              label: 'Confirmar contraseña',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDeco('Nombre', Icons.person_outline),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDeco('Apellido', Icons.person_outline),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: _inputDeco(
                'Teléfono (opcional)',
                Icons.phone_outlined,
              ).copyWith(prefixText: '+ '),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickBirthday,
              child: AbsorbPointer(
                child: TextFormField(
                  readOnly: true,
                  decoration: _inputDeco(
                    _birthday == null
                        ? 'Fecha de nacimiento (opcional)'
                        : '${_birthday!.day.toString().padLeft(2, '0')}/'
                            '${_birthday!.month.toString().padLeft(2, '0')}/'
                            '${_birthday!.year}',
                    Icons.cake_outlined,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.next,
      decoration: _inputDeco(label, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor:
          isDark ? Colors.white.withValues(alpha:0.05) : const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha:0.12)
                : Colors.black.withValues(alpha:0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha:0.12)
                : Colors.black.withValues(alpha:0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryFire, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryFire,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryFire.withValues(alpha:0.55),
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
                _isLogin ? 'Iniciar sesión' : 'Crear cuenta',
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

// Widgets auxiliares

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/promitheas_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Promitheas',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),        
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.redAccent : Colors.green;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
