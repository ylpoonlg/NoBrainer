import 'package:flutter/material.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/HomePage/NewBraincell.dart';
import 'package:nobrainer/src/HomePage/move_cell_folder.dart';

class BraincellTile extends StatelessWidget {
  final BrainCell                cell;
  final Function(BrainCell)      onEdit;
  final Function(BrainCell, int) onMove;
  final Function(BrainCell)      onDelete;
  final Function(int)            onOpenFolder;
  final Function                 reload;

  const BraincellTile({
    required this.cell,
    required this.onEdit,
    required this.onMove,
    required this.onDelete,
    required this.onOpenFolder,
    required this.reload,
    Key? key,
  }) : super(key: key);


  Widget buildBrainCellTile(context) {
    Color foregroundColor = cell.color.computeLuminance() < 0.5
      ? Colors.white
      : Colors.black;
    return Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        color: cell.color,
        child: InkWell(
          splashColor: Colors.grey.withAlpha(20),
          onTap: () {
            Widget? page = cell.getPage();
            if (page != null) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
          child:
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "   " + BrainCellType.getBrainCellTypeLabel(cell.type),
                style: TextStyle(
                  fontSize: 16,
                  color:    foregroundColor.withAlpha(80),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: foregroundColor,
              ),
              onSelected: (String value) {
                _onMenuSelect(context, value);
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(value: "edit"  , child: Text("Edit")  ),
                  PopupMenuItem(value: "move"  , child: Text("Move")  ),
                  PopupMenuItem(value: "delete", child: Text("Delete")),
                ];
              }
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: Text(
            cell.title,
            style: TextStyle(
              fontSize: 24,
              color:    foregroundColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    )
    )
    );
  }

  Widget buildFolderTile(context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () {
          onOpenFolder(cell.folderId);
        },
        child: Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: FittedBox(
                child: Icon(Icons.folder),
                fit:   BoxFit.fill,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const IconButton(onPressed: null, icon: Icon(null)),
                Expanded(
                  child: Text(
                    cell.title,
                    textAlign: TextAlign.center,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String value) {
                    _onMenuSelect(context, value);
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(value: "folder_rename"  , child: Text("Rename")  ),
                      PopupMenuItem(value: "move"  , child: Text("Move")  ),
                      PopupMenuItem(value: "delete", child: Text("Delete")),
                    ];
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onMenuSelect(BuildContext context, String value) {
    switch (value) {
      case "edit":
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewBraincell(
              isEditMode: true,
              cell:       cell,
              callback:   onEdit,
            ),
          ),
        );
        break;
      case "folder_rename":
        String folderName = "";
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Rename Folder"),
            content: TextField(
              controller: TextEditingController(text: cell.title),
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
                  cell.title = folderName;
                  onEdit(cell);
                  Navigator.of(context).pop();
                },
                child: const Text("Rename"),
              ),
            ],
          ),
        );
        break;
      case "move":
        int moveTo = 0;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Move BrainCell"),
            content: SizedBox(
              width:  MediaQuery.of(context).size.width,
              height: 320,
              child: MoveCellFolder(onFolderChanged: (folderid) {
                moveTo = folderid;
              }),
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
                  Navigator.of(context).pop();
                  onMove(cell, moveTo);
                },
                child: const Text("Move"),
              ),
            ],
          ),
        );
        break;
      case "delete":
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
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete(cell);
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: !cell.isFolder
        ? buildBrainCellTile(context)
        : buildFolderTile(context),
    );
  }
}
