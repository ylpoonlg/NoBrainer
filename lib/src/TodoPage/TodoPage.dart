import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/TodoPage/TodoItem.dart';
import 'package:nobrainer/src/TodoPage/TodoItemDetails.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

// Sorting modes
List<Map> sortingModes = [
  {
    "label": "Deadline",
    "value": "deadline",
  },
  {
    "label": "Status",
    "value": "status",
  },
];

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
      sortingModes[0]["value"]; // Sorting modes for todo items
  String displayGroup = "all"; // group to display

  _TodoPageState() : super() {
    _loadTodoList();
  }

  // Updates braincell content in database
  // Braincell must exist already in database.
  void _saveTodoList() async {
    setState(() {
      isTodoListLoaded = false;
    });

    final Database db = await DbHelper.database;
    await db.update(
      "braincells",
      {
        'uuid': widget.uuid,
        'content': json.encode(todoList),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    setState(() {
      isTodoListLoaded = true;
    });
  }

  void _loadTodoList() async {
    final Database db = await DbHelper.database;
    final List<dynamic> dbMap = await db.query(
      "braincells",
      where: "uuid = \"" + widget.uuid + "\"",
      distinct: true,
    );

    if (dbMap.isEmpty) {
      todoList = [];
    } else {
      todoList = json.decode(dbMap[0]["content"] ?? "[]");
    }

    setState(() {
      isTodoListLoaded = true;
    });
  }

  void _addTodoItem() {
    Map newItem = Map.from(defaultTodoItem);
    newItem["uuid"] = const Uuid().v1();
    newItem["deadline"] = DateTime.now().toString();
    todoList.add(newItem);
    _saveTodoList(); // Save to local storage first

    // Jump to directly to the detail page
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TodoItemDetails(
        onUpdate: _updateTodoItem,
        data: newItem,
      ),
    ));
  }

  void _deleteTodoItem(uuid) {
    todoList.removeWhere((item) {
      return item["uuid"] == uuid;
    });
    _saveTodoList();
  }

  void _updateTodoItem(data) {
    for (int i = 0; i < todoList.length; i++) {
      if (todoList[i]["uuid"] == data["uuid"]) {
        todoList[i] = data;
      }
    }
    _saveTodoList();
  }

  /// Sort the list according to the sort mode.
  ///
  /// Returns widgets of the todo list.
  List<Widget> _getTodoList() {
    List<Map> sortedList = List.from(todoList);

    sortedList.sort((i, j) {
      if (todoSortMode == "status") {
        const Map<String, int> statusValue = {
          "urgent": 1,
          "todo": 2,
          "ongoing": 3,
          "completed": 4,
        };
        int a = statusValue[i["status"]] ?? 0;
        int b = statusValue[j["status"]] ?? 0;
        return a.compareTo(b);
      }
      // Default to deadline mode
      return DateTime.parse(i["deadline"])
          .compareTo(DateTime.parse(j["deadline"]));
    });

    List<Widget> items = [];
    for (int i = 0; i < sortedList.length; i++) {
      items.add(TodoItem(
        key: Key("todoitem-" + sortedList[i]["uuid"]),
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
          PopupMenuButton(
            initialValue: todoSortMode,
            onSelected: (value) {
              setState(() {
                todoSortMode = value.toString();
              });
            },
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext context) {
              return sortingModes.map((Map mode) {
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
