import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/TodoPage/TodoItem.dart';
import 'package:nobrainer/src/TodoPage/TodoNotifier.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';

class TodoDetailsPage extends StatefulWidget {
  final TodoItem item;
  final Function(TodoItem) onEdit;

  const TodoDetailsPage({
    required this.item,
    required this.onEdit,
    Key? key
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoItemsDetailsState();
}

class _TodoItemsDetailsState extends State<TodoDetailsPage> {
  late TodoItem item;

  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  void _onSelectDeadline(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DatePickerDialog(
        initialDate: item.deadline,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialCalendarMode: DatePickerMode.day,
      ),
    ).then((date) {
      setState(() {
        // Pick Time
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(item.deadline),
        ).then((time) {
          setState(() {
            if (time != null) {
              item.deadline = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            }
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsetsGeometry listTilePadding = EdgeInsets.only(
      top: 16,
      left: 16,
      right: 16,
      bottom: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: item.id >= 0 ?
          const Text("Edit Task") : const Text("New Task"),
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onEdit(item);
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(80, 64)),
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
              controller: TextEditor.getController(item.title),
              onChanged: (text) {
                item.title = text;
              },
              decoration: const InputDecoration(
                labelText: "Task",
                hintText: "e.g. Submit Assignment, Exercise",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Description
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditor.getController(item.desc),
              onChanged: (text) {
                item.desc = text;
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
                DateTimeFormat.dateFormat(item.deadline),
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
                  // TODO: Need some way to determine the notify id
                  item.notifyid = value ? 1 : -1;
                });
              },
              value: item.notifyid >= 0,
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
