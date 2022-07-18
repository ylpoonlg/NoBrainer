import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/BrainCell/CellPage.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/TodoPage/TodoDetailsPage.dart';
import 'package:nobrainer/src/TodoPage/TodoItem.dart';
import 'package:nobrainer/src/TodoPage/TodoNotifier.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';
import 'package:sqflite/sqflite.dart';

class TodoPage extends StatefulWidget {
  final BrainCell cell;

  const TodoPage({required this.cell, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> implements CellPage<TodoItem> {
  @override
  List<TodoItem> cellItems = [];
  @override
  bool isItemsLoaded = false;

  String todoSortMode = TodoItemSort.deadline;

  _TodoPageState() {
    loadItems();
  }

  @override
  loadItems() async {
    Database db = await DbHelper.database;
    List<Map> rows = await db.query(
      DbTableName.todoItems,
      where: "cellid = ?",
      whereArgs: [widget.cell.cellid],
    );

    cellItems = [];
    for (Map row in rows) {
      cellItems.add(TodoItem.from(row));
    }

    setState(() {
      isItemsLoaded = true;
    });
  }

  @override
  newItem(TodoItem item) async {
    Database db = await DbHelper.database;
    await db.insert(
      DbTableName.todoItems,
      item.toMap(exclude: ["id"]),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    loadItems();
  }

  @override
  editItem(TodoItem item) async {
    _addNotifier(item);

    if (item.id < 0) {
      newItem(item);
      return;
    }

    Database db = await DbHelper.database;
    await db.update(
      DbTableName.todoItems,
      item.toMap(exclude: ["id", "cellid"]),
      where: "id = ?",
      whereArgs: [item.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    loadItems();
  }

  @override
  deleteItem(TodoItem item) async {
    setState(() {
      isItemsLoaded = false;
    });

    // Cancel notification if any
    item.notifytime = -1;
    await _addNotifier(item);

    Database db = await DbHelper.database;
    await db.delete(
      DbTableName.todoItems,
      where: "id = ?",
      whereArgs: [item.id],
    );

    loadItems();
  }

  _clearDoneTasks() async {
    setState(() {
      isItemsLoaded = false;
    });

    Database db = await DbHelper.database;
    await db.delete(
      DbTableName.todoItems,
      where: "cellid = ? AND status = ?",
      whereArgs: [widget.cell.cellid, TodoStatus.done],
    );

    loadItems();
  }

  _addNotifier(TodoItem item) {
    if (item.notifytime >= 0) {
      if (item.status == TodoStatus.done) {
        TodoNotifier().unscheduleNotification(item);
      } else {
        TodoNotifier().scheduleNotification(item);
      }
    } else {
      TodoNotifier().unscheduleNotification(item);
    }
  }


  void _onSelectStatus(TodoItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select a status"),
          children: [
            TodoStatus.todo,
            TodoStatus.urgent,
            TodoStatus.ongoing,
            TodoStatus.done,
          ].map((status) => SimpleDialogOption(
              onPressed: () {
                setState(() {
                  item.status = status;
                  editItem(item);
                  Navigator.of(context).pop();
                });
              },
              child: Text(TodoStatus.getStatusLabel(status)),
          )).toList(),
        );
      },
    );
  }

  @override
  Widget buildItemTile(TodoItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      horizontalTitleGap: 2,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TodoDetailsPage(
            item: item,
            onEdit: editItem,
          )
        ));
      },
      leading: RawMaterialButton(
        onPressed: () {
          _onSelectStatus(item);
        },
        fillColor: TodoStatus.getStatusColor(item.status),
        shape: const CircleBorder(),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(
        DateTimeFormat.dateFormat(item.deadline),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              key: Key("delete-task-${item.id}"),
              title: const Text("Delete Confirmation"),
              content: Text(
                "Do you want to delete task \"${item.title}\"?",
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    await deleteItem(item);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.close),
      ),
    );
  }

  List<TodoItem> sortItems() {
    List<TodoItem> sortedItems = List.from(cellItems);
    sortedItems.sort((i, j) {
      int cmpStatus = TodoStatus.compare(i.status, j.status);
      int cmpTime = i.deadline.compareTo(j.deadline);

      if (todoSortMode == TodoItemSort.status) {
        return cmpStatus == 0 ? cmpTime : cmpStatus;
      }
      return cmpTime;
    });
    return sortedItems;
  }

  @override
  List<Widget> buildItemList() {
    List<Widget> items = [];
    for (TodoItem item in sortItems()) {
      items.add(buildItemTile(item));
    }
    return items;
  }
  
  Widget buildClearDone() {
    return IconButton(
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
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await _clearDoneTasks();
                  Navigator.of(context).pop();
                },
                child: const Text("Remove"),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.remove_done),
      tooltip: "Clear completed tasks",
    );
  }

  Widget buildSortBy() {
    return PopupMenuButton(
      initialValue: todoSortMode,
      onSelected: (value) {
        setState(() {
          todoSortMode = value.toString();
        });
      },
      icon: const Icon(Icons.sort),
      tooltip: "Sort by",
      itemBuilder: (BuildContext context) {
        return [
          TodoItemSort.deadline,
          TodoItemSort.status,
        ].map((String mode) {
          return PopupMenuItem<String>(
            value: mode, child: Text(TodoItemSort.getSortModeLabel(mode)),
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cell.title),
        actions: [
          buildClearDone(),
          buildSortBy(),
        ],
      ),
      body: isItemsLoaded
        ? ListView(
          key: const Key("todolistview"),
          children: buildItemList(),
        ) : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TodoDetailsPage(
              item: TodoItem(
                cellid: widget.cell.cellid,
              ),
              onEdit: editItem,
            )
          ));
        },
      ),
    );
  }
}

