import 'package:flutter/material.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';

class BraincellTile extends StatelessWidget {
  final BrainCell           cell;
  final Widget              page;
  final Function(BrainCell) onEdit;
  final Function(BrainCell) onDelete;

  const BraincellTile({
    required this.cell,
    required this.page,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = cell.color.computeLuminance() < 0.5
      ? Colors.white
      : Colors.black;

    return Container(
      margin: const EdgeInsets.all(0),
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        color: cell.color,
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
                        PopupMenuItem(value: "edit"  , child: Text("Edit")  ),
                        PopupMenuItem(value: "delete", child: Text("Delete")),
                      ];
                    },
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
          ),
        ),
      ),
    );
  }
}
