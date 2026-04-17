import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promitheas/features/profile/providers/profile_provider.dart';
import 'package:promitheas/shared/widgets/decoration.dart';
import 'package:promitheas/shared/widgets/page_header.dart';
import 'package:promitheas/shared/widgets/status_banner.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}


//==========================================================================
//                          CLASE PRINCIPAL
//==========================================================================
class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;
  late TextEditingController _thresholdController;

  // Estado para el switch de notificaciones
  bool _notificationsEnabled = false;

  // Estados de la pantalla
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    
    // Leemos el valor actual del perfil para precargar el formulario
    // Usamos .value porque profileProvider es un AsyncNotifier
    final profile = ref.read(profileProvider).value;

    _firstNameController = TextEditingController(text: profile?.firstName ?? '');
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _birthdayController = TextEditingController(text: profile?.birthday ?? '');
    _thresholdController = TextEditingController(text: profile?.notificationThreshold.toString() ?? '0.0');
    _notificationsEnabled = profile?.notificationsEnabled ?? false;
  }

  @override
  void dispose() {
    // Limpiamos la memoria
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  // --- Lógica de guardado ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // Obtenemos el perfil actual completo para clonarlo y cambiar solo lo necesario
    final currentProfile = ref.read(profileProvider).value;
    if (currentProfile == null) return;

    // Usamos el copyWith del ProfileModel
    final updatedProfile = currentProfile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      birthday: _birthdayController.text.trim(),
      notificationsEnabled: _notificationsEnabled,
      notificationThreshold: double.tryParse(_thresholdController.text) ?? 0.0,
    );

    // Llamamos al método de actualización que hiciste en tu Notifier
    final error = await ref.read(profileProvider.notifier).updateProfile(updatedProfile);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (error != null) {
          _errorMessage = error;
        } else {
          _successMessage = '¡Perfil actualizado con éxito!';
        }
      });

      // Si todo sale bien, volvemos a la pantalla anterior después de 1 segundo
      if (error == null) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.pop();
        });
      }
    }
  }



  //==========================================================================
  //                          FORMULARIO PRINCIPAL
  //==========================================================================
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: PageHeader(icon: Icons.edit_note_rounded, title: 'EDIT PROFILE'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //--------------------------------------------------
                      //                Banners de Estado 
                      //--------------------------------------------------
                      if (_errorMessage != null) ...[
                        StatusBanner(message: _errorMessage!, isError: true),
                        const SizedBox(height: 16),
                      ], 
                      if (_successMessage != null) ...[
                        StatusBanner(message: _successMessage!, isError: false),
                        const SizedBox(height: 16),
                      ],

                      //--------------------------------------------------
                      //                Campos del Formulario
                      //--------------------------------------------------
                      TextFormField(
                        controller: _firstNameController,
                        decoration: CustomInputDeco.get(context, 'First Name', Icons.person_outline),
                        validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _lastNameController,
                        decoration: CustomInputDeco.get(context, 'Last Name', Icons.person_outline),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: CustomInputDeco.get(context, 'Phone Number', Icons.phone_outlined),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _birthdayController,
                        decoration: CustomInputDeco.get(context, 'Birthday (DD/MM/YYYY)', Icons.cake_outlined),
                      ),
                      const SizedBox(height: 32),

                      //--------------------------------------------------
                      //                  Preferencias 
                      //--------------------------------------------------
                      Text('PREFERENCES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      
                      //--- Switch para habilitar Las notificaciones ---
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Enable Notifications'),
                        value: _notificationsEnabled,
                        activeColor: primaryColor,
                        onChanged: (bool value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      
                      //--- Campo de las notificaciones ---
                      if (_notificationsEnabled) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _thresholdController,
                          keyboardType: TextInputType.number,
                          decoration: CustomInputDeco.get(context, 'Alert Threshold', Icons.notifications_active_outlined),
                        ),
                      ],

                      const SizedBox(height: 48),

                      //--------------------------------------------------
                      //              Botón de Guardado 
                      //--------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}