import 'package:flutter/material.dart';

class CalderTheme {
  static const ink = Color(0xFF101820);
  static const panel = Color(0xFF182632);
  static const cyan = Color(0xFF61E7D4);
  static const amber = Color(0xFFFFC857);
  static const muted = Color(0xFF91A5AE);

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ink,
    colorScheme: ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: Brightness.dark,
    ),
    cardTheme: const CardThemeData(color: panel, elevation: 0),
    useMaterial3: true,
  );
}
