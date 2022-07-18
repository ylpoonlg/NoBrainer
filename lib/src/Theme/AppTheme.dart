import 'dart:math';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme(String themeName) {
    if (themeName == "dark") return darkTheme;
    return lightTheme;
  }
}

class Palette {
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark  = Color(0xFF0F132A);
  static const Color foregroundLight = Color(0xFF121212);
  static const Color foregroundDark  = Color(0xFFFDFDFD);

  static const Color error           = Color(0xFFE22662);
  static const Color primary         = Color(0xFF062B5A);
  static const Color secondary       = Color(0xFFEBD5AE);
  static const Color tertiary        = Color(0xFF707299);

  static const Color positive        = Color(0xFF08CC7A);
  static const Color negative        = Color(0xFFE22662);

  static Color darken(Color color, {double weight = 0.9}) {
    return Color.fromARGB(
      255,
      min(max(0  , color.red   * weight), 255).toInt(),
      min(max(0  , color.green * weight), 255).toInt(),
      min(max(0  , color.blue  * weight), 255).toInt(),
    );
  }

  static Color lighten(Color color, {double weight = 1.1}) {
    return darken(color, weight: weight);
  }
}


ThemeData lightTheme = ThemeData.from(
  colorScheme: ColorScheme(
    brightness:   Brightness.light,
    primary:      Palette.primary,
    onPrimary:    Palette.foregroundDark,
    secondary:    Palette.secondary,
    onSecondary:  Palette.backgroundDark,
    tertiary:     Palette.tertiary,
    onTertiary:   Palette.foregroundDark,
    error:        Palette.error,
    onError:      Palette.foregroundDark,
    background:   Palette.backgroundLight,
    onBackground: Palette.foregroundLight,
    surface:      Palette.darken(Palette.backgroundLight),
    onSurface:    Palette.foregroundLight,
  ),
).copyWith(
  useMaterial3: true,
  brightness: Brightness.light,
  //
  // *** TODO: Material 3 Bug - https://github.com/flutter/flutter/issues/107305
  //
  // appBarTheme: const AppBarTheme(
  //   backgroundColor:  Palette.primary,
  //   foregroundColor:  Palette.foregroundDark,
  //   actionsIconTheme: IconThemeData(color: Palette.foregroundDark),
  //   iconTheme:        IconThemeData(color: Palette.foregroundDark),
  // ),
  checkboxTheme: CheckboxThemeData(
    checkColor: MaterialStateProperty.all(Palette.backgroundDark),
    fillColor:  MaterialStateProperty.all(Palette.secondary),
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(style: ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Palette.secondary),
    foregroundColor: MaterialStatePropertyAll(Palette.backgroundDark),
  )),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Palette.secondary,
    foregroundColor: Palette.backgroundDark,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Palette.secondary;
      }
      return Colors.grey[200];
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Palette.darken(Palette.secondary, weight: 0.8);
      }
      return Colors.grey;
    }),
  ),
);

ThemeData darkTheme = ThemeData.from(
  colorScheme: ColorScheme(
    brightness:   Brightness.dark,
    primary:      Palette.secondary,
    onPrimary:    Palette.backgroundDark,
    secondary:    Palette.tertiary,
    onSecondary:  Palette.foregroundDark,
    error:        Palette.error,
    onError:      Palette.foregroundDark,
    background:   Palette.backgroundDark,
    onBackground: Palette.foregroundDark,
    surface:      Palette.lighten(Palette.backgroundDark),
    onSurface:    Palette.foregroundDark.withOpacity(0.9),
  )
).copyWith(
  useMaterial3: true,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Palette.darken(Palette.backgroundDark),
    foregroundColor: Palette.foregroundDark,
  ),
  // Inherit from lightTheme
  checkboxTheme:             lightTheme.checkboxTheme,
  elevatedButtonTheme:       lightTheme.elevatedButtonTheme,
  floatingActionButtonTheme: lightTheme.floatingActionButtonTheme,
  switchTheme:               lightTheme.switchTheme,
);

