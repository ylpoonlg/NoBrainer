import 'package:flutter/material.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/SettingsHandler.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Settings settings = Settings();
  bool isSettingsLoaded = false;

  _SettingsPageState() {
    settings = Settings();
    loadSettings();
  }

  loadSettings() async {
    settings = await settingsHandler.getSettings();
    setState(() {
      isSettingsLoaded = true;
    });
  }


  Widget buildThemeSetting() {
    return ListTile(
      title: const Text("Dark Mode"),
      trailing: Switch(
        value: settings.themeName == "dark",
        onChanged: (value) {
          setState(() {
            settings.themeName = value ? "dark" : "light";
            settingsHandler.saveSettings(settings);
          });
        },
      ),
    );
  }


  Widget buildCurrencySetting() {
    return ListTile(
      title: const Text("Currency"),
      trailing: PopupMenuButton(
        initialValue: settings.currency,
        onSelected: (value) {
          setState(() {
            settings.currency = value.toString();
            settingsHandler.saveSettings(settings);
          });
        },
        itemBuilder: ((context) {
          return [
            PopupMenuItem(
              value: "dollar",
              child: Text(currencySymbol["dollar"] ?? ""),
            ),
            PopupMenuItem(
              value: "pound",
              child: Text(currencySymbol["pound"] ?? ""),
            ),
            PopupMenuItem(
              value: "euro",
              child: Text(currencySymbol["euro"] ?? ""),
            ),
            PopupMenuItem(
              value: "yen",
              child: Text(currencySymbol["yen"] ?? ""),
            ),
            PopupMenuItem(
              value: "ruble",
              child: Text(currencySymbol["ruble"] ?? ""),
            ),
          ];
        }),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          alignment: Alignment.center,
          width: 36,
          child: Text(currencySymbol[settings.currency] ?? "\$"),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          buildThemeSetting(),
          buildCurrencySetting(),
        ],
      ),
    );
  }
}
