import 'package:flutter/material.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/HomePage/HomePage.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/Database/db.dart';

/// WIP: For using notification to return to previous natigation state
class NavKey {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

class NoBrainerApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NoBrainerAppState();
}

class NoBrainerAppState extends State<NoBrainerApp> {
  Settings settings = Settings();
  bool isDatabaseReady = false;
  bool showPermissionMsg = false;

  NoBrainerAppState() {
    _initApp();
  }

  _initApp() async {
    // Init Database Instance
    await DbHelper().initDatabase();


    // Listen for setting changes
    settingsHandler.addListener(() async {
      settings = await settingsHandler.getSettings();
      reloadApp();
    });

    settings = await settingsHandler.getSettings();

    setState(() {
      if (DbHelper.database != null) {
        isDatabaseReady = true;
      } else {
        showPermissionMsg = true;
      }
    });
  }

  void reloadApp() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isDatabaseReady
        ? MaterialApp(
            title: 'NoBrainer',
            theme: AppTheme.theme(settings.themeName),
            home: const HomePage(),
            builder: (context, child) => MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child ?? const Text("Something went wrong..."),
            ),
            navigatorKey: NavKey.navigatorKey,
          )
        : MaterialApp(
            title: 'Loading',
            theme: AppTheme.theme("light"),
            home: Scaffold(
              body: Center(
                child: Wrap(
                  direction: Axis.vertical,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    showPermissionMsg
                        ? const Text(
                            "Please grant the\nStorage Permission from\nthe settings of your device")
                        : Container(),
                  ],
                ),
              ),
            ),
          );
  }
}
