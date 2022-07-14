import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
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
        title: const Text("Settings"),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          // Dark Mode
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

          // Currency
          ListTile(
            title: const Text("Currency"),
            trailing: PopupMenuButton(
              initialValue: widget.sh.settings["currency"] ?? "dollar",
              onSelected: (value) {
                setState(() {
                  widget.sh.settings["currency"] = value.toString();
                  widget.sh.saveSettings();
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
                child: Text(currencySymbol[
                        widget.sh.settings["currency"] ?? "dollar"] ??
                    "\$"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
