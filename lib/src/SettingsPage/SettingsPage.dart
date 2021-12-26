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
          Container(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
            child: Row(
              children: [
                const Text("Dark Mode"),
                const Spacer(),
                Switch(
                  value: (widget.sh.settings["theme"] ?? "light") == "dark",
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() {
                      widget.sh.settings["theme"] = value ? "dark" : "light";
                      widget.sh.saveSettings();
                    });
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
