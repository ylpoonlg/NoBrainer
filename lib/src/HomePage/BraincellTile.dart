import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/HomePage/NewBraincell.dart';

class BraincellTile extends StatelessWidget {
  Map cell;
  Widget page;
  Function onEdit, onDelete;

  BraincellTile({
    required this.cell,
    required this.page,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = cell["color"];

    // Calculate the the brightness of the tile and use suitable foreground color
    final Color foregroundColor =
        AppTheme.getColorBrightness(backgroundColor) < 0.5
            ? AppTheme.color["white"]
            : AppTheme.color["black"];

    return Container(
      margin: const EdgeInsets.all(5),
      child: Card(
        color: cell["color"],
        child: InkWell(
          splashColor: Colors.grey.withAlpha(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "    " + typeLabel[cell["type"]].toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: foregroundColor.withAlpha(80),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  PopupMenuButton(
                    onSelected: (value) {
                      switch (value) {
                        case "edit":
                          onEdit(cell);
                          break;
                        case "delete":
                          onDelete(cell);
                          break;
                      }
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: foregroundColor,
                    ),
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(value: "edit", child: Text("Edit")),
                        PopupMenuItem(value: "delete", child: Text("Delete")),
                      ];
                    },
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  cell["name"],
                  style: TextStyle(
                    fontSize: 24,
                    color: foregroundColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
