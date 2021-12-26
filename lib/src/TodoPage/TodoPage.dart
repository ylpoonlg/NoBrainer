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
  List<Map> todoList = [];

  _TodoPageState() : super();

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

  void _saveTodoList() {
    setState(() {
      storage.setItem("todolist", todoList);
    });
  }

  void _addTodoItem() {
    todoList.add({
      "uuid": const Uuid().v1(),
      "title": "New Todo Item " + Random().nextInt(256).toString(),
      "status": "Incomplete",
      "deadline": "09/05/2003",
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Todo List"),
      ),
      body: ListView(
        key: const Key("todolistview"),
        children: _getTodoList(),
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
