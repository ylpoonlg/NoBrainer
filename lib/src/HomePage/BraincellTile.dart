import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class BraincellTile extends StatelessWidget {
  String title, type;
  Color color;
  Widget page;

  BraincellTile({
    required this.title,
    required this.color,
    required this.page,
    this.type = "",
    Key? key,
  }) : super(key: key);

  void _editBraincell() {
    debugPrint("Edit braincell");
  }

  void _deleteBraincell() {
    debugPrint("Delete braincell");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Card(
        color: color,
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
                      "    " + type,
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
                          _editBraincell();
                          break;
                        case "delete":
                          _deleteBraincell();
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
                  title,
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
