import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // --- MODO CLARO ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryFire,
        surface: AppColors.surfaceLight,
      ),
      // Botón: Naranja con texto Blanco (como en tu mockup)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryFire,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50), // Tamaño base
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Bordes redondeados
          ),
        ),
      ),
      // Menú inferior: Gris inactivo, Naranja activo
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryFire,
        unselectedItemColor: AppColors.navBarInactive,
        backgroundColor: AppColors.backgroundLight,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false, // En tu diseño no hay texto en los iconos
        showUnselectedLabels: false,
      ),
    );
  }

  // --- MODO OSCURO ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryFire,
        surface: AppColors.surfaceDark,
      ),
      // Botón: Blanco con texto Naranja (como en tu mockup)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryFire,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      // Menú inferior para modo oscuro
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryFire,
        unselectedItemColor: AppColors.navBarInactive,
        backgroundColor: AppColors.backgroundDark,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
