import 'package:flutter/material.dart';
import 'package:nobrainer/src/FinancePage/Currencies.dart';
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
      leading: const Icon(Icons.dark_mode),
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
      leading: const Icon(Icons.currency_exchange),
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
            Currencies.dollar,
            Currencies.pound,
            Currencies.euro,
            Currencies.yen,
            Currencies.ruble,
          ].map((currency) => PopupMenuItem(
            value: currency,
            child: Text(
              Currencies.getCurrencySymbol(currency),
            ),
          )).toList();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4,
          ),
          alignment: Alignment.center,
          width: 36,
          child: Text(Currencies.getCurrencySymbol(settings.currency)),
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
