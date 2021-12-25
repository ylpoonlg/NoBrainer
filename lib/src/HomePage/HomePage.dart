import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/ClipPage/ClipPage.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/SettingsPage/SettingsPage.dart';
import 'package:nobrainer/src/ShopPage/ShopPage.dart';
import 'package:nobrainer/src/TimerPage/TimerPage.dart';
import 'package:nobrainer/src/TodoPage/TodoPage.dart';
import 'package:nobrainer/src/app.dart';

class HomePage extends StatefulWidget {
  SettingsHandler sh;
  HomePage(this.sh);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> getToolList() {
    return [
      ToolItem(
        title: "Todo List",
        color: AppTheme.color["cyan"],
        page: TodoPage(),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "No Brainer",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
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
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(widget.sh)));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          children: getToolList(),
        ),
      ),
    );
  }
}

class ToolItem extends StatelessWidget {
  var title, color, page;

  ToolItem({title, color, page}) : super() {
    this.title = title;
    this.color = color;
    this.page = page;
  }

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
            padding: EdgeInsets.all(30),
            child: Text(title,
                style: TextStyle(fontSize: 24, color: AppTheme.color["white"])),
          ),
        ),
      ),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.all(Radius.circular(10))),
    );
  }
}
