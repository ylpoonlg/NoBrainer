import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/TodoPage/TodoNotifier.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';

class TodoItemDetails extends StatefulWidget {
  Map data;
  Function onUpdate;

  TodoItemDetails({required this.data, required this.onUpdate, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _TodoItemsDetailsState(new Map.from(data));
}

class _TodoItemsDetailsState extends State<TodoItemDetails> {
  final Map data;
  _TodoItemsDetailsState(this.data);

  void _onSelectDeadline(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DatePickerDialog(
        initialDate: DateTime.parse(data["deadline"]),
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialCalendarMode: DatePickerMode.day,
      ),
    ).then((date) {
      setState(() {
        // Pick Time
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(DateTime.parse(data["deadline"])),
        ).then((time) {
          setState(() {
            if (time != null) {
              data["deadline"] = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              ).toString();
            }
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    const EdgeInsetsGeometry listTilePadding = EdgeInsets.only(
      top: 16,
      left: 16,
      right: 16,
      bottom: 0,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Edit Todo Task"),
        actions: [
          MaterialButton(
            onPressed: () {
              widget.onUpdate(data);
              Navigator.of(context).pop();
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Title
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditor.getController(data["title"]),
              onChanged: (text) {
                data["title"] = text;
              },
              decoration: const InputDecoration(
                labelText: "Title",
                hintText: "Enter the title of the task",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Description
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditor.getController(data["desc"]),
              onChanged: (text) {
                data["desc"] = text;
              },
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "Describe the task",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Deadline
          ListTile(
            contentPadding: listTilePadding,
            title: const Text("Deadline"),
            trailing: MaterialButton(
              onPressed: () {
                _onSelectDeadline(context);
              },
              child: Text(
                DateTimeFormat.dateFormat(DateTime.parse(data["deadline"])),
              ),
            ),
          ),

          // Notification
          ListTile(
            contentPadding: listTilePadding,
            title: const Text("Notification"),
            trailing: Switch(
              onChanged: (value) {
                setState(() {
                  data["notify"] = value;
                });
              },
              value: data["notify"] ?? false,
              activeColor: AppTheme.color["accent-primary"],
            ),
            // trailing: MaterialButton(
            //   onPressed: () async {
            //     await TodoNotifier().scheduleNotification(data);
            //   },
            //   child: const Text("Test"),
            // ),
          ),
        ],
      ),
    );
  }
}
