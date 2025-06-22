import 'package:flutter/material.dart';

final lightColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.deepPurple,
  brightness: Brightness.light,
  background: const Color(0xFFF8F9FA),
  surface: Colors.white,
  onSurface: Colors.black,
);

final darkColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.deepPurple,
  brightness: Brightness.dark,
  background: const Color(0xFF121212),
  surface: const Color(0xFF1E1E1E),
  onSurface: Colors.white,
);

final lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: lightColorScheme.background,
  appBarTheme: AppBarTheme(
    backgroundColor: lightColorScheme.surface,
    foregroundColor: lightColorScheme.onSurface,
    elevation: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.red.shade400,
    contentTextStyle: const TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
  ),
);

final darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: darkColorScheme.background,
  appBarTheme: AppBarTheme(
    backgroundColor: darkColorScheme.surface,
    foregroundColor: darkColorScheme.onSurface,
    elevation: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.red.shade300,
    contentTextStyle: const TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
  ),
);
