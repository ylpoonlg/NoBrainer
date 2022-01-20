import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/HomePage/BraincellTile.dart';
import 'package:nobrainer/src/HomePage/ImportBraincell.dart';
import 'package:nobrainer/src/HomePage/NewBraincell.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/SettingsPage/SettingsPage.dart';
import 'package:nobrainer/src/ShopPage/ShopPage.dart';
import 'package:nobrainer/src/TodoPage/TodoPage.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  final SettingsHandler sh;
  const HomePage({required this.sh, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> braincells = [];
  bool isExpandAddOptions = false;
  bool isBraincellsLoaded = false;

  _HomePageState() {
    _loadBraincells();
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

  /// Save braincells to local database
  /// Created new row if haven't already
  _saveBraincell() async {
    setState(() {
      isBraincellsLoaded = false;
    });

    final Database db = await DbHelper.database;
    for (final cell in braincells) {
      debugPrint("Saving braincell " + cell["uuid"]);

      // Create value map for insert/update operations
      final values = {
        'props': json.encode({
          "name": cell["name"],
          "type": cell["type"],
          "imported": cell["imported"],
          "color": {
            "red": cell["color"].red,
            "green": cell["color"].green,
            "blue": cell["color"].blue,
            "opacity": cell["color"].opacity,
          },
        }),
      };

      // Check if braincell exists
      final dbMap = await db.query(
        "braincells",
        where: "uuid = \"" + cell["uuid"] + "\"",
      );
      if (dbMap.isEmpty) {
        values["uuid"] = cell["uuid"];
        values["content"] = "[]";
        await db.insert(
          "braincells",
          values,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint("Created cell: " + cell["uuid"]);
      } else {
        final result = await db.update(
          "braincells",
          values,
          where: 'uuid = "' + cell["uuid"] + '"',
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint("Updated " + cell["uuid"] + ": $result");
      }
    }

    final dbMap = await db.query("braincells");
    debugPrint("Current braincells in db: \n" + dbMap.toString());

    setState(() {
      isBraincellsLoaded = true;
    });
  }

  /// Restore braincells from local database
  /// Sets isBraincellsLoaded = true when complete
  _loadBraincells() async {
    final Database db = await DbHelper.database;
    final List<dynamic> dbMap = await db.query("braincells");

    if (dbMap.isEmpty) {
      braincells = [];
    } else {
      braincells = [];
      debugPrint(dbMap.toString());
      for (var row in dbMap) {
        final props = json.decode(row["props"]);
        braincells.add({
          "uuid": row["uuid"],
          "name": props["name"],
          "type": props["type"],
          "imported": props["imported"],
          "color": Color.fromRGBO(
            props["color"]["red"],
            props["color"]["green"],
            props["color"]["blue"],
            props["color"]["opacity"],
          ),
        });
      }
    }

    setState(() {
      isBraincellsLoaded = true;
    });
  }

  /// Add new braincell to state list
  /// Either created or imported
  _newBraincell(cell) {
    braincells.add(cell);
    _saveBraincell();
  }

  _editBraincell(cell) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewBraincell(
          isEditMode: true,
          cell: cell,
          callback: (cell) {
            for (var i = 0; i < braincells.length; i++) {
              if (braincells[i]["uuid"] == cell["uuid"]) {
                braincells[i] = Map.from(cell);
              }
            }
            _saveBraincell();
          },
        ),
      ),
    );
  }

  _deleteBraincell(cell) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Confirmation"),
        content: const Text("Are you sure you want to delete this braincell?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              braincells.removeWhere((cell) => cell["uuid"] == cell["uuid"]);

              setState(() {
                isBraincellsLoaded = false;
              });

              final Database db = await DbHelper.database;
              await db.delete(
                "braincells",
                where: "uuid = ?",
                whereArgs: [cell["uuid"]],
              );

              _loadBraincells();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  /// Returns a list of BraincellTiles
  List<Widget> getBraincellList() {
    return braincells
        .map(
          (cell) => BraincellTile(
            cell: cell,
            page: cellMap(cell)["page"],
            onDelete: _deleteBraincell,
            onEdit: _editBraincell,
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
      // New Button
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
      // Import Button
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

    // Expand button
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

  ///
  ///
  ///
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
        child: !isBraincellsLoaded
            ? Center(
                child: CircularProgressIndicator(
                  color: AppTheme.color["accent-primary"],
                ),
              )
            : GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                children: getBraincellList(),
              ),
      ),
    );
  }
}
