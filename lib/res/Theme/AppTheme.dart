import 'dart:ffi';

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme(String themeName) {
    if (themeName == "dark") return darkTheme;
    return lightTheme;
  }

  static Map color = colors;

  /// Returns the preceived brightness of a color
  /// Value ranges from 0.0 to 1.0, the higher the value the brighter the color
  static double getColorBrightness(Color color) {
    return 0.3 * color.red / 255.0 +
        0.59 * color.green / 255.0 +
        0.11 * color.blue / 255.0;
  }
}

const colors = {
  "appbar-background": Color.fromARGB(255, 29, 87, 134),
  "accent-primary": Color.fromARGB(255, 240, 99, 17),
  "red": Color.fromARGB(255, 189, 11, 11),
  "green": Color.fromARGB(255, 12, 180, 20),
  "blue": Color.fromARGB(255, 4, 38, 131),
  "cyan": Color.fromARGB(255, 14, 212, 238),
  "magenta": Color.fromARGB(255, 221, 26, 195),
  "yellow": Color.fromARGB(255, 240, 225, 17),
  "orange": Color.fromARGB(255, 240, 99, 17),
  "purple": Color.fromARGB(255, 134, 44, 175),
  "teal": Color.fromARGB(255, 7, 194, 169),
  "white": Color.fromARGB(255, 248, 248, 248),
  "light-gray": Color.fromARGB(255, 175, 175, 175),
  "gray": Color.fromARGB(255, 56, 58, 59),
  "black": Color.fromARGB(255, 15, 15, 15),
};

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  backgroundColor: const Color.fromARGB(255, 248, 248, 248),
  primaryColor: colors["accent-primary"],
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  backgroundColor: const Color.fromARGB(255, 45, 45, 46),
  primaryColor: colors["accent-primary"],
);
