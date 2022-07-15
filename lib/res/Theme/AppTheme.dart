import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ThemeData theme(String themeName) {
    if (themeName == "dark") return darkTheme;
    return lightTheme;
  }

  static Map color = colors;
  static Map icon = icons;


  // Pending removal {
  static Map colorToMap(Color clr) {
    return {
      "red": clr.red,
      "green": clr.green,
      "blue": clr.blue,
      "opacity": clr.opacity,
    };
  }
  static Color mapToColor(Map xmap) {
    return Color.fromRGBO(
      xmap["red"],
      xmap["green"],
      xmap["blue"],
      xmap["opacity"],
    );
  }
  // } Pending removal
}

const colors = {
  "light-background": Color(0xFFFAFAFA),
  "light-card": Color(0xFFAFAFAF),
  "dark-background": Color(0xFF011C27),
  "dark-card": Color(0xAA011C27),
  "appbar-background": Color(0xFF062B5A),
  "accent-primary": Color(0xFFEBD5AE),
  "accent-secondary": Color(0xFF545677),
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

const icons = {
  "general": Icons.interests,
  "shop": Icons.local_mall,
  "food": Icons.food_bank,
  "grocery": Icons.local_grocery_store,
  "train": Icons.train,
  "people": Icons.people,
  "bill": Icons.receipt,
  "custom": Icons.brush,
  "savings": Icons.savings,
  "bitcoin": Icons.currency_bitcoin,
  "holiday": Icons.flight,
  "celebration": Icons.celebration,
  "sport": Icons.directions_bike,
  "computer": Icons.computer,
  "phone": Icons.phone,
  "house": Icons.house,
  "car": Icons.directions_car,
  "clothes": Icons.checkroom,
  "square": Icons.square,
  "circle": Icons.circle,
};


class Palette {
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark  = Color(0xFF0F132A);
  static const Color foregroundLight = Color(0xFF121212);
  static const Color foregroundDark  = Color(0xFFFDFDFD);

  static const Color error           = Color(0xFFE22662);
  static const Color primary         = Color(0xFF062B5A);
  static const Color secondary       = Color(0xFFEBD5AE);
  static const Color tertiary        = Color(0xFF707299);

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
  floatingActionButtonTheme: lightTheme.floatingActionButtonTheme,
  switchTheme: lightTheme.switchTheme,
);

