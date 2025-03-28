import 'package:flutter/material.dart';

class MyThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'TH_Mali',
    scaffoldBackgroundColor: Colors.grey[100],
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light, // ✅ เพิ่มตรงนี้ให้ตรงกับ ThemeData
    ),
    useMaterial3: true,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'TH_Mali',
    focusColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[900],
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark, // ✅ เพิ่มตรงนี้ให้ตรงกับ ThemeData
    ),
    useMaterial3: true,
  );
}
