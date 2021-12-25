import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsHandler sh;
  SettingsPage(this.sh);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
            child: Row(
              children: [
                Text("Dark Mode"),
                Spacer(),
                Switch(
                  value: (widget.sh.settings["theme"] ?? "light") == "dark",
                  onChanged: (value) {
                    setState(() {
                      print("Toggle Button: $value");
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
