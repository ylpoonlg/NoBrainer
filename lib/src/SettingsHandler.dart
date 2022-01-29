import 'dart:convert';

import 'package:nobrainer/src/Database/db.dart';
import 'package:sqflite/sqflite.dart';

class SettingsHandler {
  Function reloadApp;

  /// Default settings
  Map<String, String> settings = {
    "theme": "light",
    "currency": "dollar",
  };

  SettingsHandler(this.reloadApp) {
    loadSettings();
    saveSettings();
  }

  loadSettings() async {
    final Database? db = await DbHelper.database;
    if (db == null) return;

    final dbMap = await db.query("settings");
    for (var item in dbMap) {
      settings[item["name"].toString()] = item["value"].toString();
    }

    reloadApp();
  }

  saveSettings() async {
    final Database db = await DbHelper.database;
    settings.forEach((key, value) {
      db.insert(
        "settings",
        {
          "name": key,
          "value": value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    reloadApp();
  }
}
