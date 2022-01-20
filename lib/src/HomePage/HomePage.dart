import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/HomePage/BraincellTile.dart';
import 'package:nobrainer/src/HomePage/ImportBraincell.dart';
import 'package:nobrainer/src/HomePage/NewBraincell.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/SettingsPage/SettingsPage.dart';
import 'package:nobrainer/src/ShopPage/ShopPage.dart';
import 'package:nobrainer/src/TodoPage/TodoPage.dart';

class HomePage extends StatefulWidget {
  final SettingsHandler sh;
  const HomePage({required this.sh, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> braincells = [];
  bool isExpandAddOptions = false;

  _HomePageState() {
    braincells.add({
      "uuid": "TESTINGUUID",
      "name": "Default Test TodoList",
      "type": "todolist",
      "imported": false,
      "color": AppTheme.color["green"],
    }); // For debug only
  }

  Map cellMap(cell) {
    if (cell["type"] == "todolist") {
      return {
        "page": TodoPage(
          uuid: cell["uuid"],
        ),
      };
    } else if (cell["type"] == "shoplist") {
      return {
        "page": ShopPage(
          uuid: cell["uuid"],
        ),
      };
    } else {
      return {
        "page": TodoPage(
          uuid: cell["uuid"],
        ),
      };
    }
  }

  _newBraincell(cell) {
    setState(() {
      braincells.add(cell);
    });
  }

  List<Widget> getBraincellList() {
    return braincells
        .map(
          (cell) => BraincellTile(
            title: cell["name"],
            type: typeLabel[cell["type"]] ?? "", // Get label name from value
            color: cell["color"],
            page: cellMap(cell)["page"],
          ),
        )
        .toList();
  }

  /// Returns a list of floating action buttons.
  ///
  /// Controls the expansion of the add action buttons.
  List<Widget> getFloatingActionButtons() {
    List<Widget> items = [];
    if (isExpandAddOptions) {
      items.add(TextButton(
        onPressed: () {
          setState(() {
            isExpandAddOptions = false;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewBraincell(callback: _newBraincell),
              ),
            );
          });
        },
        child: const Text("New Braincell"),
        style: TextButton.styleFrom(
          primary: AppTheme.color["white"],
          backgroundColor: AppTheme.color["gray"],
        ),
      ));
      items.add(TextButton(
        onPressed: () {
          setState(() {
            isExpandAddOptions = false;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ImportBraincell(
                callback: _newBraincell,
              ),
            ));
          });
        },
        child: const Text("Import Braincell from cloud"),
        style: TextButton.styleFrom(
          primary: AppTheme.color["white"],
          backgroundColor: AppTheme.color["gray"],
        ),
      ));
    }
    items.add(Container(
      margin: const EdgeInsets.only(top: 15),
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            isExpandAddOptions = !isExpandAddOptions;
          });
        },
        backgroundColor: AppTheme.color["accent-primary"],
        foregroundColor: AppTheme.color["white"],
        child: isExpandAddOptions
            ? const Icon(Icons.close)
            : const Icon(Icons.add),
      ),
    ));
    return items;
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
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: getFloatingActionButtons(),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          children: getBraincellList(),
        ),
      ),
    );
  }
}
