import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/AboutPage/AboutPage.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/FinancePage/FinancePage.dart';
import 'package:nobrainer/src/HomePage/BraincellTile.dart';
import 'package:nobrainer/src/HomePage/ImportBraincell.dart';
import 'package:nobrainer/src/HomePage/NewBraincell.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/SettingsPage/SettingsPage.dart';
import 'package:nobrainer/src/ShopPage/ShopPage.dart';
import 'package:nobrainer/src/TodoPage/TodoPage.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //List<Map<String, dynamic>> braincells = [];
  List<BrainCell> braincells = [];
  bool isExpandAddOptions = false;
  bool isBraincellsLoaded = false;

  int folderParent = 0;

  _HomePageState() {
    _loadBraincells();
  }

  /// Save braincells to local database
  /// Created new row if haven't already
  _saveBraincell() async {
    setState(() {
      isBraincellsLoaded = false;
    });

    final Database db = await DbHelper.database;

    for (int i = 0; i < braincells.length; i++) {
      BrainCell cell = braincells[i];

      // Save to table BrainCells
      if (!cell.isFolder) {
        Map<String, Object?> newCell = {
          "name": cell.title,
          "type": cell.type,
          "color": cell.color.value,
          "settings": json.encode(cell.settings),
        };
        if (cell.cellid != -1) {
          newCell["cellid"] = cell.cellid;
        }
        await db.insert("BrainCells",
          newCell,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );


        List<Map> rowid = await db.rawQuery("SELECT last_insert_rowid();");
        if (rowid.isNotEmpty) {
          List<Map> lastRow = await db.query("Braincells",
            where: "rowid = ?", whereArgs: [rowid[0]["last_insert_rowid()"]],
          );
          cell.cellid = lastRow[0]["cellid"];
        }
      }

      // Save to table CellFolders
      Map<String, Object?> newFolder = {
        "cellid": cell.cellid,
        "orderid": i,
        "name": cell.title,
        "parent": folderParent,
      };
      List<Map> folder = await db.query("CellFolders",
        where: "cellid = ?", whereArgs: [cell.cellid],
      );
      if (folder.isNotEmpty) {
        newFolder["id"] = folder[0]["id"];
      }
      await db.insert("CellFolders",
        newFolder,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    

    setState(() {
      isBraincellsLoaded = true;
    });
  }

  /// Restore braincells from local database
  /// Sets isBraincellsLoaded = true when complete
  _loadBraincells() async {
    final Database db = await DbHelper.database;
    final List<Map> folders = await db.query("CellFolders",
      where: "parent = ?", whereArgs: [folderParent],
      orderBy: "orderid",
    );

    braincells = [];
    for (Map folder in folders) {
      bool isFolder = folder["cellid"] == -1;
      if (isFolder) {
        braincells.add(BrainCell(
          title: folder["name"], isFolder: true,
        ));
      } else {
        List<Map> braincell = await db.query("Braincells",
          where: "cellid = ?", whereArgs: [folder["cellid"]],
        );
        if (braincell.isEmpty) continue;
        braincells.add(BrainCell(
          cellid: folder["cellid"],
          title: braincell[0]["name"],
          type: braincell[0]["type"],
          color: Color(braincell[0]["color"]),  // Debug
          settings: json.decode(braincell[0]["settings"]),
        ));
      }
    }

    setState(() {
      isBraincellsLoaded = true;
    });
  }

  /// Add new braincell to state list
  /// Either created or imported
  _newBraincell(BrainCell cell) {
    bool newCell = true;
    for (var i = 0; i < braincells.length; i++) {
      if (braincells[i].cellid == cell.cellid) {
        braincells[i] = cell;
        newCell = false;
        break;
      }
    }
    if (newCell) {
      braincells.add(cell);
    }
    _saveBraincell();
  }

  _editBraincell(BrainCell cell) {
    setState(() {
      isExpandAddOptions = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewBraincell(
          isEditMode: true,
          cell: cell,
          callback: (cell) {
            for (var i = 0; i < braincells.length; i++) {
              if (braincells[i].cellid == cell.cellid) {
                braincells[i] = cell;
              }
            }
            _saveBraincell();
          },
        ),
      ),
    );
  }

  _deleteBraincell(BrainCell cell) {
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
              braincells.removeWhere((cell2) => cell2.cellid == cell.cellid);

              setState(() {
                isBraincellsLoaded = false;
              });

              final Database db = await DbHelper.database;
              await db.delete(
                "Braincells",
                where: "cellid = ?",
                whereArgs: [cell.cellid],
              );

              _loadBraincells();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  _onReorder(oldIndex, newIndex) {
    final cell = braincells.removeAt(oldIndex);
    braincells.insert(newIndex, cell);
    _saveBraincell();
  }

  /// Returns a list of BraincellTiles
  List<Widget> getBraincellList() {
    return braincells.map(
          (BrainCell cell) => BraincellTile(
            key: Key("braincell-tile-" + cell.cellid.toString()),
            cell: cell,
            page: cell.getPage(),
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
    items.add(Container(
      margin: const EdgeInsets.only(top: 15),
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewBraincell(
                  cell: BrainCell(title: "New Cell"),
                  callback: _newBraincell,
                ),
              ),
            );
          });
        },
        child: const Icon(Icons.add),
      ),
    ));
    return items;
  }



  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double braincellTilesAR = (screenWidth > screenHeight) ? 2 : 1.2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("NoBrainer"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Palette.primary,
              ),
              child: Text(
                'NoBrainer',
                style: TextStyle(
                  color: Palette.foregroundDark,
                  fontSize: 24,
                ),
              ),
            ),
            // About
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                setState(() {
                  isExpandAddOptions = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ),
                  );
                });
              },
            ),
            // Settings
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  isExpandAddOptions = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    ),
                  );
                });
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
        child: !isBraincellsLoaded ?
          const Center(
            child: CircularProgressIndicator(),
          ) :
          Container(
            child: ReorderableGridView.count(
              crossAxisCount: 2,
              childAspectRatio: braincellTilesAR,
              mainAxisSpacing: 15,
              crossAxisSpacing: 12,
              children: getBraincellList(),
              onReorder: _onReorder,
              padding: const EdgeInsets.only(
                top: 20, left: 20, right: 20, bottom: 85,
              ),
            ),
          ),
      ),
    );
  }
}
