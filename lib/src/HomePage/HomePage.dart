import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/ClipPage/ClipPage.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/SettingsPage/SettingsPage.dart';
import 'package:nobrainer/src/ShopPage/ShopPage.dart';
import 'package:nobrainer/src/TimerPage/TimerPage.dart';
import 'package:nobrainer/src/TodoPage/TodoPage.dart';

class HomePage extends StatefulWidget {
  SettingsHandler sh;
  HomePage({required this.sh, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> getToolList() {
    return [
      ToolItem(
        title: "Todo List",
        color: AppTheme.color["cyan"],
        page: TodoPage(
          uuid: "tEst1ngUulD",
        ),
      ),
      ToolItem(
        title: "Shopping List",
        color: AppTheme.color["green"],
        page: ShopPage(),
      ),
      ToolItem(
        title: "Clipboard",
        color: AppTheme.color["magenta"],
        page: ClipPage(),
      ),
      ToolItem(
        title: "Timer",
        color: AppTheme.color["orange"],
        page: TimerPage(),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text(
          "No Brainer",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'No Brainer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(sh: widget.sh)));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: screenWidth / (screenHeight - 120),
          children: getToolList(),
        ),
      ),
    );
  }
}

class ToolItem extends StatelessWidget {
  String title;
  Color color;
  Widget page;

  ToolItem({
    required this.title,
    required this.color,
    required this.page,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Text(title,
                style: TextStyle(fontSize: 24, color: AppTheme.color["white"])),
          ),
        ),
      ),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
    );
  }
}
