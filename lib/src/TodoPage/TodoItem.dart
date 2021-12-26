import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TodoItem extends StatefulWidget {
  Map data;
  Function onDelete, onUpdate;

  TodoItem(
      {required Map this.data,
      required Function this.onDelete,
      required this.onUpdate,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoItemState(data);
}

class _TodoItemState extends State<TodoItem> {
  String status = "Incomplete";

  _TodoItemState(data) {
    status = data["status"];
  }

  void _onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: const Key("todoitemalert"),
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
                  widget.onDelete(widget.data["uuid"]);
                  Navigator.of(context).pop();
                },
                child: const Text("Confirm")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          DropdownButton(
            value: status,
            items: const [
              DropdownMenuItem(value: "Incomplete", child: Text("Incomplete")),
              DropdownMenuItem(value: "On-going", child: Text("On-going")),
              DropdownMenuItem(value: "Completed", child: Text("Completed")),
            ],
            onChanged: (val) {
              setState(() {
                status = val.toString();
                widget.data["status"] = val;
                widget.onUpdate(widget.data);
              });
            },
          ),
          Text(widget.data["title"]),
          const Spacer(),
          IconButton(
              onPressed: () {
                _onDelete(context);
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
    );
  }
}
