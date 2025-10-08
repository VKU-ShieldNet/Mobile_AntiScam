// lib/app/theme/app_theme.dart
// Purpose: Central place for ThemeData, color schemes, and text styles.
// How to use: Import and use AppTheme.theme in MaterialApp.

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );
}
