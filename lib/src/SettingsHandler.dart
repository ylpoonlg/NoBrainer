import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsHandler {
  Function reloadApp;

  Map settings = {
    "theme": "light",
  };

  SettingsHandler(this.reloadApp) {
    loadSettings();
  }

  void loadSettings() {
    SharedPreferences.getInstance().then((pref) {
      settings =
          json.decode(pref.getString("settings") ?? json.encode(settings));
      reloadApp();
    });
  }

  void saveSettings() {
    SharedPreferences.getInstance().then((pref) {
      pref.setString("settings", json.encode(settings));
      reloadApp();
    });
  }
}
