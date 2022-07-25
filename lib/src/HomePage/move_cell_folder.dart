import 'package:flutter/material.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:sqflite/sqflite.dart';

class MoveCellFolder extends StatefulWidget {
  final Function(int) onFolderChanged;
  
  const MoveCellFolder({
    required this.onFolderChanged,
    Key? key,
  }) : super(key: key);

  @override
    State<StatefulWidget> createState() => _MoveCellFolder();
}

class _MoveCellFolder extends State<MoveCellFolder> {
  List<BrainCell> folders = [];
  List<int> folderParent = [0];
  bool isFoldersLoaded = false;

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  loadFolders() async {
    widget.onFolderChanged(folderParent.last);

    Database db = DbHelper.database;
    List<Map> rows = await db.query(
      DbTableName.cellFolders,
      where: "parent = ? AND cellid = ?",
      whereArgs: [folderParent.last, -1],
      orderBy: "orderid",
    );

    folders = [];
    for (Map folder in rows) {
      folders.add(BrainCell(
        folderId: folder["id"],
        title:    folder["name"],
        isFolder: true,
      ));
    }

    setState(() {
      isFoldersLoaded = true;
    });
  }
  
  List<Widget> buildFolders() {
    List<Widget> items = [];
    
    if (folderParent.length > 1) {
      items.add(ListTile(
        onTap: () {
          folderParent.removeLast();
          setState(() {
            isFoldersLoaded = false;
          });
          loadFolders();
        },
        leading: const Icon(Icons.arrow_upward),
        title:   const Text(".."),
      ));
    } else {
      //items.add(const ListTile());
    }

    for (BrainCell cell in folders) {
      items.add(ListTile(
        onTap: () {
          folderParent.add(cell.folderId);
          setState(() {
            isFoldersLoaded = false;
          });
          loadFolders();
        },
        leading: const Icon(Icons.folder),
        title:   Text(cell.title),
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: buildFolders(),
      ),
    );
  }
}
