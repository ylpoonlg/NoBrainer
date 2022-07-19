import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:sqflite/sqflite.dart';

// Global Instance
SettingsHandler settingsHandler = SettingsHandler();

class SettingsHandler with ChangeNotifier {
  Future<Settings> getSettings() async {
    Database db = DbHelper.database;
    Settings result = Settings();

    List<Map> settingsTable = await db.query("Settings");
    for (var row in settingsTable) {
      result.setValue(row["name"], row["value"].toString());
    }

    return result;
  }

  void saveSettings(Settings settings) async {
    Database db = DbHelper.database;
    settings.toMap().forEach((key, value) {
      db.insert(
        "Settings",
        {
          "name": key,
          "value": value.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    notifyListeners();
  }
}


class Settings {
  // Default settings
  String themeName;
  String currency;

  Settings({
    this.themeName = "light",
    this.currency  = "dollar",
  });

  setValue(String key, String value) {
    switch (key) {
      case "themeName":
        themeName = value;
        break;
      case "currency":
        currency = value;
        break;
    }
  }

  Map<String, String> toMap() {
    return {
      "themeName":       themeName,
      "currency":        currency,
    };
  }
}
