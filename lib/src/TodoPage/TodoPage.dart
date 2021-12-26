import 'dart:math';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/TodoPage/TodoItem.dart';
import 'package:uuid/uuid.dart';

class TodoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final LocalStorage storage = LocalStorage("nobrainer");
  List<dynamic> todoList = [];

  _TodoPageState() : super();

  // Todo List Processing
  void _saveTodoList() {
    setState(() {
      storage.setItem("todolist", todoList);
    });
  }

  void _addTodoItem() {
    Map newItem = Map.from(defaultTodoItem);
    newItem["uuid"] = const Uuid().v1();
    newItem["deadline"] = DateTime.now().toString();
    todoList.add(newItem);
    _saveTodoList();
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

  /// Returns widgets of the todo list
  List<Widget> _getTodoList() {
    todoList = storage.getItem("todolist") ?? [];
    List<Widget> items = [];
    for (int i = 0; i < todoList.length; i++) {
      items.add(TodoItem(
        key: Key("todoitem-" + todoList[i]["uuid"]),
        data: todoList[i],
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
            onPressed: () {},
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.group),
          ),
        ],
      ),
      body: FutureBuilder(
        future: storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.color["accent-primary"],
              ),
            );
          }
          return ListView(
            key: const Key("todolistview"),
            children: _getTodoList(),
          );
        },
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
