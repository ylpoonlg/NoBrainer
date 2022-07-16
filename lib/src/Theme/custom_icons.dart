import 'package:flutter/material.dart';

class CustomIcons {
  static IconData? getIcon(String name) {
    return _icons[name];
  }

  static String getIconString(IconData? icon) {
    String iconString = "";
    _icons.forEach((key, value) {
      if (value == icon) iconString = key;
    });
    return iconString;
  }

  static List<IconData> getIcons() {
    return _icons.values.toList();
  }
}

const Map<String, IconData> _icons = {
  "general":     Icons.interests,
  "shop":        Icons.local_mall,
  "food":        Icons.food_bank,
  "grocery":     Icons.local_grocery_store,
  "train":       Icons.train,
  "people":      Icons.people,
  "bill":        Icons.receipt,
  "custom":      Icons.brush,
  "savings":     Icons.savings,
  "bitcoin":     Icons.currency_bitcoin,
  "holiday":     Icons.flight,
  "celebration": Icons.celebration,
  "sport":       Icons.directions_bike,
  "computer":    Icons.computer,
  "phone":       Icons.phone,
  "house":       Icons.house,
  "car":         Icons.directions_car,
  "clothes":     Icons.checkroom,
  "square":      Icons.square,
  "circle":      Icons.circle,
};
