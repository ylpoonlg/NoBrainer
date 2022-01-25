import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/FinancePage/FinanceItem.dart';
import 'package:nobrainer/src/FinancePage/FinanceItemDetails.dart';

import 'package:sqflite/sqflite.dart';

class FinancePage extends StatefulWidget {
  final String uuid;

  FinancePage({required String this.uuid});

  @override
  State<StatefulWidget> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  List<dynamic> financeList = []; // Current status of the shopping list
  bool isFinanceListLoaded = false;

  _FinancePageState() : super() {
    _loadFinanceList();
  }

  // Updates braincell content in database
  // Braincell must exist already in database.
  void _saveFinanceList() async {
    final Database db = await DbHelper.database;
    await db.update(
      "braincells",
      {
        'content': json.encode(financeList),
      },
      where: "uuid = ?",
      whereArgs: [widget.uuid],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    setState(() {
      isFinanceListLoaded = true;
    });
  }

  void _loadFinanceList() async {
    final Database db = await DbHelper.database;
    final List<dynamic> dbMap = await db.query(
      "braincells",
      where: "uuid = ?",
      whereArgs: [widget.uuid],
      distinct: true,
    );

    if (dbMap.isEmpty) {
      financeList = [];
    } else {
      financeList = json.decode(dbMap[0]["content"] ?? "[]");
    }

    setState(() {
      isFinanceListLoaded = true;
    });
  }

  void _addFinanceItem() {
    Map newItem = Map.from(defaultFinanceItem);
    newItem["id"] = "finance-item-" + financeList.length.toString();
    newItem["time"] = DateTime.now().toString();
    financeList.add(newItem);
    _saveFinanceList(); // Save to local storage first

    // Jump to directly to the detail page
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FinanceItemDetails(
        onUpdate: _updateFinanceItem,
        data: newItem,
      ),
    ));
  }

  void _deleteFinanceItem(id) {
    financeList.removeWhere((item) {
      return item["id"] == id;
    });
    // Update id
    for (int i = 0; i < financeList.length; i++) {
      financeList[i]["id"] = "finance-item-" + i.toString();
    }
    _saveFinanceList();
  }

  void _updateFinanceItem(data) {
    for (int i = 0; i < financeList.length; i++) {
      if (financeList[i]["id"] == data["id"]) {
        financeList[i] = data;
        break;
      }
    }
    _saveFinanceList();
  }

  /// Sort the list according to the sort mode.
  ///
  /// Returns widgets of the shopping list.
  List<Widget> _getShopList() {
    List<Map> sortedList = List.from(financeList);

    List<Widget> items = [];
    for (int i = 0; i < sortedList.length; i++) {
      items.add(FinanceItem(
        key: Key("financeitem-" + sortedList[i]["id"]),
        data: sortedList[i],
        onDelete: _deleteFinanceItem,
        onUpdate: _updateFinanceItem,
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Finance"),
        actions: [],
      ),
      body: isFinanceListLoaded
          ? ListView(
              key: const Key("financelistview"),
              children: _getShopList(),
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
        onPressed: _addFinanceItem,
      ),
    );
  }
}
