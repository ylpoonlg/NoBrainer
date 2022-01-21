import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/SettingsHandler.dart';

class SettingsPage extends StatefulWidget {
  SettingsHandler sh;
  SettingsPage({required this.sh, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Settings"),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          ListTile(
            title: const Text("Dark Mode"),
            trailing: Switch(
              value: (widget.sh.settings["theme"] ?? "light") == "dark",
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                setState(() {
                  widget.sh.settings["theme"] = value ? "dark" : "light";
                  widget.sh.saveSettings();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
