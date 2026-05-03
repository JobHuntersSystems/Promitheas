import 'package:flutter/material.dart';

class AppColors {
  // Color Corporativo Principal
  static const Color primaryFire = Color(0xFFFF6A00);

  // Modo Oscuro (Basado en el azul muy oscuro de tu mockup)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Modo Claro (Blanco puro como en tu diseño)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAFC);

  // Grises para la barra de navegación inferior
  static const Color navBarInactive = Color.fromARGB(255, 202, 202, 202);

  // Textos
  static const Color textPrimary   = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary  = Color(0xFFC7C7CC);

  // Sombras y shimmer
  static const Color cardShadow       = Color(0x0F000000);
  static const Color shimmerBase      = Color(0xFFE5E5EA);
  static const Color shimmerHighlight = Color(0xFFF2F2F7);

  // Estados de peligro
  static const Color danger = Color(0xFFFF3B30);

  // Paleta de colores para iconos de carpetas
  static const Color folderOrange = primaryFire;
  static const Color folderBlue   = Color(0xFF4B9CD3);
  static const Color folderPurple = Color(0xFF9C6FDE);
  static const Color folderGreen  = Color(0xFF34B67A);
  static const Color folderPink   = Color(0xFFE05B7B);
  static const Color folderTeal   = Color(0xFF2BB5A0);

  static const List<Color> folderPalette = [
    folderOrange,
    folderBlue,
    folderPurple,
    folderGreen,
    folderPink,
    folderTeal,
  ];
}
