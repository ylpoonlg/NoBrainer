import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white60,
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
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
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
                    color: AppTheme.color["white"],
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
