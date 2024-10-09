import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightDefault = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color.fromRGBO(201, 82, 80, 1),
      onPrimary: Colors.white,
      secondary: Color.fromRGBO(201, 91, 89, 1),
      onSecondary: Colors.black,
      surface: Color.fromRGBO(255, 247, 247, 1),
      onSurface: Colors.black,
      surfaceContainer: Color.fromRGBO(247, 228, 228, 1),
    ),
  );

  static final ThemeData darkDefault = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
        primary: Color.fromRGBO(119, 24, 22, 1),
        onPrimary: Colors.white,
        secondary: Color.fromRGBO(145, 34, 32, 1),
        onSecondary: Colors.white,
        surface: Color.fromRGBO(40, 40, 40, 1),
        onSurface: Colors.white,
        surfaceContainer: Color.fromRGBO(63, 63, 63, 1)),
  );
}
