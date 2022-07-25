import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/AboutPage/AboutPage.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/HomePage/BraincellTile.dart';
import 'package:nobrainer/src/HomePage/NewBraincell.dart';
import 'package:nobrainer/src/SettingsPage/SettingsPage.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BrainCell> braincells = [];
  bool isBraincellsLoaded = false;

  List<int> folderParent = [0];
  Map<int, String> folderName = {0: "root"};

  _HomePageState() {
    _loadBraincells();
  }

  _loadBraincells() async {
    Database db = DbHelper.database;
    final List<Map> folders = await db.query(
      DbTableName.cellFolders,
      where: "parent = ?", whereArgs: [folderParent.last],
      orderBy: "orderid",
    );

    braincells = [];
    for (Map folder in folders) {
      bool isFolder = folder["cellid"] == -1;
      if (isFolder) {
        folderName[folder["id"]] = folder["name"];
        braincells.add(BrainCell(
          title:    folder["name"],
          folderId: folder["id"],
          isFolder: true,
        ));
      } else {
        List<Map> braincell = await db.query(
          DbTableName.braincells,
          where: "cellid = ?", whereArgs: [folder["cellid"]],
        );
        if (braincell.isEmpty) continue;
        braincells.add(BrainCell(
          folderId: folder["id"],
          cellid:   folder["cellid"],
          title:    braincell[0]["name"],
          type:     braincell[0]["type"],
          color:    Color(braincell[0]["color"]),
          isFolder: false,
          settings: json.decode(braincell[0]["settings"]),
        ));
      }
    }

    setState(() {
      isBraincellsLoaded = true;
    });
  }

  _newBraincell(BrainCell cell) async {
    Database db = DbHelper.database;
    await db.insert(
      DbTableName.braincells,
      cell.toBrainCellsMap(exclude: ["cellid"]),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Get cellid
    List<Map> rowid   = await db.rawQuery("SELECT last_insert_rowid();");
    List<Map> lastRow = await db.query(
      DbTableName.braincells,
      where: "rowid = ?", whereArgs: [rowid[0]["last_insert_rowid()"]],
    );
    cell.cellid = lastRow[0]["cellid"];

    await db.insert(
      DbTableName.cellFolders,
      {
        "cellid":  cell.cellid,
        "orderid": braincells.length,
        "name":    cell.title,
        "parent":  folderParent.last,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await _loadBraincells();
    return cell.cellid;
  }

  _editBraincell(BrainCell cell) async {
    Database db = DbHelper.database;

    if (!cell.isFolder) {
      await db.update(
        DbTableName.braincells,
        cell.toBrainCellsMap(exclude: ["cellid"]),
        where: "cellid = ?",
        whereArgs: [cell.cellid],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.update(
        DbTableName.cellFolders,
        {
          "name": cell.title,
        },
        where: "id = ?",
        whereArgs: [cell.folderId],
      );
    }

    _loadBraincells();
  }

  _cloneBraincell(BrainCell cell) async {
    int oldCellid = cell.cellid;
    cell.cellid = -1;
    cell.title = "Copy of " + cell.title;
    int newCellid = await _newBraincell(cell);

    setState(() {
      isBraincellsLoaded = false;
    });

    Database db = DbHelper.database;
    for (String tbName in [
      DbTableName.todoItems,
      DbTableName.shopItems,
      DbTableName.moneyPitItems,
    ]) {
      List<Map<String, Object?>> items = await db.query(
        tbName,
        where: "cellid = ?",
        whereArgs: [oldCellid],
      );

      for (Map<String, Object?> item in items) {
        Map<String, Object?> newItem = Map.from(item);
        newItem["cellid"] = newCellid;
        newItem.remove("id");
        await db.insert(
          tbName,
          newItem,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    setState(() {
      isBraincellsLoaded = true;
    });
  }

  _deleteBraincell(BrainCell cell) async {
    setState(() {
      isBraincellsLoaded = false;
    });

    Database db = DbHelper.database;
    await db.delete(
      DbTableName.braincells,
      where: "cellid = ?",
      whereArgs: [cell.cellid],
    );

    await db.delete(
      DbTableName.cellFolders,
      where: "id = ?",
      whereArgs: [cell.folderId],
    );

    _loadBraincells();
  }

  _onNewFolder(String title) async {
    Database db = DbHelper.database;
    List<Map> folders = await db.query(DbTableName.cellFolders);
    Map<String, Object?> map = {
      "cellid":  -1,
      "orderid": braincells.length,
      "name":    title,
      "parent":  folderParent.last,
    };
    if (folders.isEmpty) {
      map["id"] = 1;
    }
    await db.insert(
      DbTableName.cellFolders,
      map,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await _loadBraincells();
  }

  _onOpenFolder(int folderId) {
    setState(() {
      isBraincellsLoaded = false;
    });
    int index = folderParent.indexOf(folderId);
    if (index == -1) {
      folderParent.add(folderId);
    } else {
      folderParent = folderParent.sublist(0, index + 1);
    }
    _loadBraincells();
  }

  _onMoveFolder(BrainCell cell, int parent) async {
    Database db = DbHelper.database;
    List<Map> cells = await db.query(
      DbTableName.cellFolders,
      where: "parent = ?",
      whereArgs: [parent],
    );

    int orderid = cells.length;
    await db.update(
      DbTableName.cellFolders,
      {
        "orderid": orderid,
        "parent":  parent,
      },
      where: "id = ?",
      whereArgs: [cell.folderId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _loadBraincells();
  }

  _onReorder(oldIndex, newIndex) async {
    BrainCell cell = braincells.removeAt(oldIndex);
    braincells.insert(newIndex, cell);

    Database db = DbHelper.database;
    int i = 0;
    for (BrainCell cell in braincells) {
      await db.update(
        DbTableName.cellFolders,
        {
          "orderid": i,
        },
        where: "id = ?",
        whereArgs: [cell.folderId],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      i++;
    }

    await _loadBraincells();
  }

  /// Returns a list of BraincellTiles
  List<Widget> getBraincellList() {
    return braincells.map((BrainCell cell) => BraincellTile(
        key: Key("braincell-tile-${cell.folderId}-${cell.cellid}"),
        cell: cell,
        onDelete:     _deleteBraincell,
        onMove:       _onMoveFolder,
        onEdit:       _editBraincell,
        onClone:      _cloneBraincell,
        onOpenFolder: _onOpenFolder,
        reload: () {
          setState(() {
            isBraincellsLoaded = false;
          });
          _loadBraincells();
        },
      )
    ).toList();
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


  Widget buildFolderNav() {
    double screenWidth  = MediaQuery.of(context).size.width;
    List<String> folderNames = [];
    for (int i = 1; i < folderParent.length; i++) {
      String? name = folderName[folderParent[i]];
      folderNames.add(name ?? "folder");
    }
    return Container(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton(
            onPressed: folderParent.length > 1
              ? () {
                  folderParent.removeLast();
                  _onOpenFolder(folderParent.last);
                }
              : null,
            icon: const Icon(Icons.arrow_upward),
          ),
          Container(
            width: screenWidth - 160,
            child: Text(
              folderNames.join(" > "),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final double screenWidth  = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double braincellTilesAR = (screenWidth > screenHeight) ? 2 : 1.2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("NoBrainer"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              String folderName = "";
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("New Folder"),
                  content: TextField(
                    onChanged: (value) {
                      folderName = value;
                    },
                    decoration: const InputDecoration(
                      labelText: "Folder Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        _onNewFolder(folderName);
                        Navigator.of(context).pop();
                      },
                      child: const Text("Create"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
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
        child: !isBraincellsLoaded
          ? const Center(
            child: CircularProgressIndicator(),
          )
          : braincells.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(0),
                  child: ReorderableGridView.count(
                    //shrinkWrap: true,
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
                )
              : const Text(
                  "No BrainCells found"
                  "\n\n"
                  "Create a new BrainCell by tapping the '+' icon",
                  textAlign: TextAlign.center,
                ),
      ),

      bottomSheet: buildFolderNav(),
    );
  }
}
