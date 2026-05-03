import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// ── Helpers de persistencia ──────────────────────────────────────────────────

Future<File> _prefsFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/app_prefs.json');
}

/// Llama esto en main() ANTES de runApp para obtener el valor guardado.
Future<bool> loadDarkMode() async {
  try {
    final file = await _prefsFile();
    if (!await file.exists()) return false;
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return data['darkMode'] as bool? ?? false;
  } catch (_) {
    return false;
  }
}

Future<void> _saveDarkMode(bool isDark) async {
  try {
    final file = await _prefsFile();
    await file.writeAsString(jsonEncode({'darkMode': isDark}));
  } catch (_) {}
}

// ── Notifier (síncrono, igual que antes) ────────────────────────────────────

class ThemeNotifier extends Notifier<ThemeMode> {
  ThemeNotifier(this._initialDark);
  final bool _initialDark;

  @override
  ThemeMode build() => _initialDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = next;
    _saveDarkMode(next == ThemeMode.dark); // guarda {"darkMode": true/false}
  }
}

// El Provider público — se sobreescribe con el valor leído en main()
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  () => ThemeNotifier(false),
);
