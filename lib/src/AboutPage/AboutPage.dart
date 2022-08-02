import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    const double iconSize = 120;
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
              top: 50,
              bottom: 35,
              left: imageHorPadding,
              right: imageHorPadding,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                "assets/icon/icon.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "NoBrainer is an app that allows you to do everyday tasks"
              " without using your brain"
              ,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          const SizedBox(height: 20),

          const ListTile(
            title: Text("Developer"),
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

          const SizedBox(height: 50),

          Text(
            "Feature Requests/Bug Reports",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          ListTile(
            title: const Text("GitHub"),
            trailing: TextButton(
              onPressed: () async {
                Uri githubUri = Uri.parse(
                  "https://github.com/ylpoonlg/NoBrainer"
                );
                if (await canLaunchUrl(githubUri)) {
                  await launchUrl(
                    githubUri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: const Text(
                "github.com/ylpoonlg/NoBrainer",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
