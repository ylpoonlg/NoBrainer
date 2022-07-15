import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "---";

  _AboutPageState() : super() {
    _loadVersion();
  }

  _loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      if (version[0] == "0") version += " (beta)";
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double iconSize = 96;
    final double imageHorPadding = (screenWidth - iconSize) / 2.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("About App"),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 8,
              bottom: 16,
              left: imageHorPadding,
              right: imageHorPadding,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/icon/icon.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const ListTile(
            title: Text("Introduction"),
            subtitle: Text('''
NoBrainer is an app that lets you do everyday tasks without using your brain.
Create Braincells of different types to aid your living!'''),
          ),
          const ListTile(
            title: Text("Developer"),
            subtitle: Text("GitHub: ylpoonlg, Website: ylpoonlg.com"),
            trailing: Text("ylpoonlg"),
          ),
          ListTile(
            title: const Text("Version"),
            subtitle: const Text("More stuff coming soon!!!"),
            trailing: Text(version),
          ),
          ListTile(
            title: const Text("Database Version"),
            trailing: Text(DbHelper.dbVersion.toString()),
          ),
        ],
      ),
    );
  }
}
