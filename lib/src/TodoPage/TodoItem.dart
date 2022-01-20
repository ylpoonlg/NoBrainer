import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/TodoPage/TodoItemDetails.dart';

// Default TodoItem
Map defaultTodoItem = {
  "id": "set todo item id",
  "status": "todo",
  "deadline": "a datetime object",
  "title": "New Task",
  "desc": "",
};

class TodoItem extends StatefulWidget {
  Map data;
  Function onDelete, onUpdate;

  TodoItem({
    required Map this.data,
    required Function this.onDelete,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoItemState(data);
}

class _TodoItemState extends State<TodoItem> {
  String status = todoStatus[0]["value"];

  _TodoItemState(data) {
    status = data["status"] ?? status;
  }

  /// Show delete confirmation popup.
  ///
  /// If confirmed, call the callback function.
  void _onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: Key("delete-alert-" + widget.data["id"]),
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  widget.onDelete(widget.data["id"]);
                  Navigator.of(context).pop();
                },
                child: const Text("Confirm")),
          ],
        );
      },
    );
  }

  /// Handles status selection.
  ///
  /// Calls back the updated data.
  void _onSelectStatus(BuildContext context) {
    List<Widget> _getStatusOptions() {
      List<Widget> options = [];
      for (int i = 0; i < todoStatus.length; i++) {
        options.add(SimpleDialogOption(
          onPressed: () {
            setState(() {
              status = todoStatus[i]["value"];
              widget.data["status"] = status;
              widget.onUpdate(widget.data);
              Navigator.of(context).pop();
            });
          },
          child: Text(todoStatus[i]["label"]),
        ));
      }
      return options;
    }

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select a status"),
          children: _getStatusOptions(),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    for (int i = 0; i < todoStatus.length; i++) {
      if (todoStatus[i]["value"] == status) {
        return todoStatus[i]["color"];
      }
    }
    return AppTheme.color["gray"];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TodoItemDetails(
                    onUpdate: widget.onUpdate,
                    data: widget.data,
                  )));
        },
        child: Row(
          children: [
            RawMaterialButton(
              onPressed: () {
                _onSelectStatus(context);
              },
              fillColor: _getStatusColor(status),
              shape: const CircleBorder(),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.data["title"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Container(height: 5),
                    Text(
                      dateFormat(DateTime.parse(widget.data["deadline"])),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  _onDelete(context);
                },
                icon: const Icon(Icons.close)),
          ],
        ),
      ),
    );
  }
}
