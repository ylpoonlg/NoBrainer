import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/FinancePage/AnalysisPage.dart';
import 'package:nobrainer/src/FinancePage/CategoryList.dart';
import 'package:nobrainer/src/FinancePage/FinanceFilter.dart';
import 'package:nobrainer/src/FinancePage/FinanceItem.dart';
import 'package:nobrainer/src/FinancePage/FinanceItemDetails.dart';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class FinancePage extends StatefulWidget {
  final String uuid;

  const FinancePage({required this.uuid, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  List<dynamic> financeList = []; // Current status of the finance list
  bool isFinanceListLoaded = false;

  Map filter = {
    "cats": [],
    "paymethod": [],
    "date-from": null,
    "date-to": null,
  };

  List<Map> categories = [];

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

    await CategoryListState.getCategories();

    setState(() {
      isFinanceListLoaded = true;
    });
  }

  void _addFinanceItem(bool spendingMode) {
    Map newItem = Map.from(defaultFinanceItem);
    newItem["id"] = "finance-item-" + const Uuid().v1();
    newItem["time"] = DateTime.now().toString();
    newItem["spending"] = spendingMode;
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

  bool _isFilterSet() {
    return !filter["cats"].isEmpty ||
        filter["date-from"] != null ||
        filter["date-to"] != null ||
        !filter["paymethod"].isEmpty;
  }

  /// Sort the list according to the sort mode.
  ///
  /// Returns widgets of the finance list.
  List<Widget> _getFinanceList() {
    List<Map> sortedList = List.from(financeList);

    // Sort list
    sortedList.sort(
      (i, j) => j["time"].compareTo(i["time"]),
    ); // Sort by descending time

    /// Returns whether any of the shops is in the filtered list of shops.
    bool catInFilter(String cat) {
      if (filter["cats"].isEmpty) return true;
      for (Map catMap in filter["cats"]) {
        if (cat == catMap["cat"]) return true;
      }
      return false;
    }

    bool payMethodInFilter(String payMethod) {
      if (filter["paymethod"].isEmpty) return true;
      for (String item in filter["paymethod"]) {
        if (payMethod == item) return true;
      }
      return false;
    }

    bool dateInFilter(DateTime dt) {
      if (filter["date-from"] != null) {
        if (dt.compareTo(filter["date-from"]) < 0) return false;
      }
      if (filter["date-to"] != null) {
        if (dt.compareTo(filter["date-to"].add(const Duration(days: 1))) > 0) {
          return false;
        }
      }
      return true;
    }

    List<Widget> items = [];
    for (int i = 0; i < sortedList.length; i++) {
      if (catInFilter(sortedList[i]["cat"]) &&
          dateInFilter(DateTime.parse(sortedList[i]["time"])) &&
          payMethodInFilter(sortedList[i]["paymethod"] ?? "")) {
        Map catData = {
          "cat": "",
          "icon": Icons.close,
          "color": Colors.transparent,
        };
        CategoryListState.categories.forEach((cat) {
          if (cat["cat"] == sortedList[i]["cat"]) {
            catData = cat;
          }
        });

        items.add(FinanceItem(
          key: Key(sortedList[i]["id"] + const Uuid().v1()),
          data: sortedList[i],
          catData: catData,
          onDelete: _deleteFinanceItem,
          onUpdate: _updateFinanceItem,
        ));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Finance"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AnalysisPage(financeList: financeList),
              ));
            },
            icon: const Icon(Icons.analytics),
          ),
          IconButton(
            // Filter Button
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FinanceFilter(
                    filter: filter,
                    onApply: (newFilter) {
                      setState(() {
                        filter = newFilter;
                      });
                    },
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.filter_list,
              color: _isFilterSet()
                  ? AppTheme.color["accent-primary"]
                  : AppTheme.color["white"],
            ),
            tooltip: "Filter and Sort",
          ),
        ],
      ),
      body: isFinanceListLoaded
          ? ListView(
              key: const Key("financelistview"),
              children: _getFinanceList(),
            )
          : Center(
              child: CircularProgressIndicator(
                color: AppTheme.color["accent-primary"],
              ),
            ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: FloatingActionButton(
              heroTag: "finance-income-button",
              backgroundColor: AppTheme.color["accent-secondary"],
              foregroundColor: AppTheme.color["white"],
              child: const Icon(Icons.trending_up),
              onPressed: () {
                _addFinanceItem(false);
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: FloatingActionButton(
              heroTag: "finance-spending-button",
              backgroundColor: AppTheme.color["accent-primary"],
              foregroundColor: AppTheme.color["white"],
              child: const Icon(Icons.credit_card),
              onPressed: () {
                _addFinanceItem(true);
              },
            ),
          ),
        ],
      ),
    );
  }
}
