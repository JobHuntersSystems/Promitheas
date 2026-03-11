import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// El Notifier que guarda el estado. Por defecto, usa el tema del sistema.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  // Método que llamaremos desde un botón en la app para cambiar de modo
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

// El Provider público que escucharás desde tu main.dart y tus botones
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
