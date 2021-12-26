import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/HomePage/HomePage.dart';
import 'package:nobrainer/src/SettingsHandler.dart';

class NoBrainerApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NoBrainerAppState();
}

class NoBrainerAppState extends State<NoBrainerApp> {
  SettingsHandler sh = SettingsHandler(() {});

  NoBrainerAppState() {
    sh = SettingsHandler(() {
      reloadApp();
    });
  }

  void reloadApp() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'No Brainer',
      theme: AppTheme.theme(sh.settings["theme"] ?? "light"),
      home: HomePage(sh: sh),
    );
  }
}
