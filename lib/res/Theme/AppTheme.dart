import 'package:flutter/material.dart';

class AppTheme {
  String getThemeName() {
    return "light";
  }

  ThemeData theme() {
    String themeName = getThemeName();
    if (themeName == "dark") return darkTheme;
    return lightTheme;
  }
}

ThemeData lightTheme = ThemeData(
  backgroundColor: Colors.white,
  primarySwatch: Colors.blueGrey,
);

ThemeData darkTheme = ThemeData(
  backgroundColor: Colors.black,
  primarySwatch: Colors.blueGrey,
);
