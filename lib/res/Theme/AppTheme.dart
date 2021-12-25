import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static ThemeData theme(String themeName) {
    if (themeName == "dark") return darkTheme;
    return lightTheme;
  }

  static Map color = colors;
}

const colors = {
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
  "black": Color.fromARGB(255, 15, 15, 15),
  "gray": Color.fromARGB(255, 56, 58, 59),
};

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  backgroundColor: colors["white"],
  primarySwatch: Colors.blueGrey,
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  backgroundColor: colors["black"],
  primarySwatch: Colors.blueGrey,
);
