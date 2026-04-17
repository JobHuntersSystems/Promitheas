import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promitheas/core/router/router_names.dart';
import 'package:promitheas/core/theme/theme_provider.dart';
import 'package:promitheas/shared/widgets/page_header.dart';
import 'package:promitheas/features/profile/providers/profile_provider.dart';

class ProfileViewScreen extends ConsumerWidget {
  const ProfileViewScreen({super.key});

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorTema = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colorTema, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildCleanRow(BuildContext context, String label, String value, {bool isImportant = true}) {
    final textColor = Theme.of(context).colorScheme.onSurface; 
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: textColor.withValues(alpha: 0.6))),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: isImportant ? FontWeight.bold : FontWeight.normal, color: textColor)),
        ],
      ),
    );
  }

  //============================================================
  //               Construcción de la página
  //============================================================

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    // Temas del sistema
    final primaryColor = Theme.of(context).colorScheme.primary; 
    final dividerColor = Theme.of(context).dividerColor; 
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        // 3. LA MAGIA DE RIVERPOD: .when() gestiona los 3 estados
        child: profileState.when(
          
          // Cargando
          loading: () => const Center(child: CircularProgressIndicator()),
          
          // Error por si algo no furula
          error: (error, stack) => Center(child: Text('Error loading profile: $error')),
          
          // =============================================
          //              Pantalla de datos
          // =============================================
          data: (userData) {
            // ------------------------------------------
            //       Scroll con todos los elementos
            // ------------------------------------------
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: PageHeader(icon: Icons.person_rounded, title: 'MY PROFILE'),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ------------------------------------------
                        //         Fotito y rol del usuario
                        // ------------------------------------------
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: primaryColor.withValues(alpha: 0.1),
                                child: Icon(Icons.person, size: 40, color: primaryColor),
                              ),
                              const SizedBox(height: 12),
                              Chip(
                                // ¡AQUÍ ESTÁ LA MAGIA! userData.role
                                label: Text(userData.role.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: primaryColor)),
                                backgroundColor: Colors.transparent,
                                side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        ),

                        // ------------------------------------------
                        //   Opción modo oscuro (Super mega witch)
                        // ------------------------------------------
                        _buildSectionTitle(context, 'App Settings'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Theme.of(context).colorScheme.onSurface),
                                  const SizedBox(width: 12),
                                  Text('Dark Mode', style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                              Switch(
                                value: isDarkMode,
                                activeThumbColor: primaryColor,
                                onChanged: (_) {
                                  ref.read(themeProvider.notifier).toggleTheme();
                                },
                              ),
                            ],
                          ),
                        ),

                        Divider(height: 32, color: dividerColor),

                        // ------------------------------------------
                        //            Datos personales
                        // ------------------------------------------
                        _buildSectionTitle(context, 'Personal Information'),
                        _buildCleanRow(context, 'Full Name', '${userData.firstName} ${userData.lastName}'),
                        _buildCleanRow(context, 'Birthday', userData.birthday.isEmpty ? 'Not set' : userData.birthday, isImportant: false),
                        
                        Divider(height: 32, color: dividerColor),

                        // ------------------------------------------
                        //                Contactos
                        // ------------------------------------------
                        _buildSectionTitle(context, 'Contact Details'),
                        _buildCleanRow(context, 'Email', userData.email),
                        _buildCleanRow(context, 'Phone', userData.phone.isEmpty ? 'No phone' : userData.phone),
                        
                        Divider(height: 32, color: dividerColor),

                        // ------------------------------------------
                        //          Opciones de preferncia
                        // ------------------------------------------
                        _buildSectionTitle(context, 'Preferences'),
                        _buildCleanRow(context, 'Notifications', userData.notificationsEnabled ? 'Enabled' : 'Disabled'),
                        if (userData.notificationsEnabled) 
                          _buildCleanRow(context, 'Alert Threshold', userData.notificationThreshold.toString()),

                        const SizedBox(height: 48),

                        // ------------------------------------------
                        //       Botón de cambiar información
                        // ------------------------------------------
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push(RouteNames.userConfig),
                            icon: const Icon(Icons.edit, size: 20),
                            label: const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // ------------------------------------------
                        //        Botón de Salir de la cuenta...
                        // ------------------------------------------
                        Center(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                            onPressed: () => context.go(RouteNames.login),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}