import 'package:flutter/material.dart';

final lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.deepPurple,
  onPrimary: Colors.white,
  secondary: Colors.purpleAccent,
  onSecondary: Colors.white,
  error: Colors.red,
  onError: Colors.white,
  surface: Colors.white,
  onSurface: Colors.black,
  tertiary: Colors.deepPurple.shade100,
  onTertiary: Colors.black,
  primaryContainer: Colors.deepPurple.shade100,
  onPrimaryContainer: Colors.black,
  secondaryContainer: Colors.purple.shade100,
  onSecondaryContainer: Colors.black,
);

final darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.deepPurple.shade200,
  onPrimary: Colors.black,
  secondary: Colors.purpleAccent,
  onSecondary: Colors.black,
  error: Colors.redAccent,
  onError: Colors.black,
  surface: const Color(0xFF1E1E1E),
  onSurface: Colors.white,
  tertiary: Colors.deepPurple.shade700,
  onTertiary: Colors.white,
  primaryContainer: Colors.deepPurple.shade700,
  onPrimaryContainer: Colors.white,
  secondaryContainer: Colors.purple.shade700,
  onSecondaryContainer: Colors.white,
);
