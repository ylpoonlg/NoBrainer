import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/TodoPage/TodoItem.dart';
import 'package:nobrainer/src/TodoPage/TodoItemDetails.dart';
import 'package:nobrainer/src/TodoPage/TodoNotifier.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class TodoPage extends StatefulWidget {
  final String uuid;
  const TodoPage({Key? key, required String this.uuid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<dynamic> todoList = []; // Current status of the todo list
  bool isTodoListLoaded = false;

  String todoSortMode =
      todoSortModes[0]["value"]; // Sorting modes for todo items
  String displayGroup = "all"; // group to display

  _TodoPageState() {
  }


  /// Sort the list according to the sort mode.
  ///
  /// Returns widgets of the todo list.
  List<Widget> _getTodoList() {
    List<Map> sortedList = List.from(todoList);

    sortedList.sort((i, j) {
      const Map<String, int> statusValue = {
        "urgent": 1,
        "todo": 2,
        "ongoing": 3,
        "completed": 4,
      };
      var iStatus = statusValue[i["status"]] ?? 0;
      var jStatus = statusValue[j["status"]] ?? 0;
      var iTime = DateTime.parse(i["deadline"]);
      var jTime = DateTime.parse(j["deadline"]);

      if (todoSortMode == "status") {
        int cmpStatus = iStatus.compareTo(jStatus);
        // If same status, sort by deadline
        return cmpStatus == 0 ? iTime.compareTo(jTime) : cmpStatus;
      }
      // Default to deadline mode
      return iTime.compareTo(jTime);
    });

    List<Widget> items = [];
    for (int i = 0; i < sortedList.length; i++) {
      items.add(TodoItem(
        key: Key("todoitem-" + const Uuid().v1()),
        data: sortedList[i],
        onDelete: _deleteTodoItem,
        onUpdate: _updateTodoItem,
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Todo List"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  key: const Key("clear-done-tasks"),
                  title: const Text("Delete Confirmation"),
                  content: const Text(
                      "Are you sure you want to remove all the done tasks?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          _clearDoneTasks();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Confirm")),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.remove_done),
            tooltip: "Clear completed tasks",
          ),
          PopupMenuButton(
            initialValue: todoSortMode,
            onSelected: (value) {
              setState(() {
                todoSortMode = value.toString();
              });
            },
            icon: const Icon(Icons.sort),
            tooltip: "Sort",
            itemBuilder: (BuildContext context) {
              return todoSortModes.map((Map mode) {
                return PopupMenuItem<String>(
                    value: mode["value"], child: Text(mode["label"]));
              }).toList();
            },
          ),
        ],
      ),
      body: isTodoListLoaded
          ? ListView(
              key: const Key("todolistview"),
              children: _getTodoList(),
            )
          : Center(
              child: CircularProgressIndicator(
                color: AppTheme.color["accent-primary"],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.color["accent-primary"],
        foregroundColor: AppTheme.color["white"],
        child: const Icon(Icons.add),
        onPressed: _addTodoItem,
      ),
    );
  }
}
