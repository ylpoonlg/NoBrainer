import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/BrainCell/CellPage.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/MoneyPage/Currencies.dart';
import 'package:nobrainer/src/MoneyPage/FinanceFilter.dart';
import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';
import 'package:nobrainer/src/MoneyPage/MoneyDetailsPage.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/MoneyPage/AnalysisPage.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';

import 'package:sqflite/sqflite.dart';

class MoneyPage extends StatefulWidget {
  final BrainCell cell;

  const MoneyPage({required this.cell, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> implements CellPage<MoneyItem> {
  @override
  List<MoneyItem> cellItems = [];
  @override
  bool isItemsLoaded = false;

  String currency = "\$";

  Map filter = {
    "cats": [],
    "paymethod": [],
    "date-from": null,
    "date-to": null,
  };

  _MoneyPageState() {
    loadItems();
  }


  @override
  loadItems() async {
    // Load currency
    Settings settings = await settingsHandler.getSettings();
    currency = Currencies.getCurrencySymbol(settings.currency);

    Database db = await DbHelper.database;

    List<Map> rows = await db.query(
      DbTableName.moneyPitItems,
      where: "cellid = ?",
      whereArgs: [widget.cell.cellid],
    );

    cellItems = [];
    for (Map row in rows) {
      MoneyCategory? category =
        await MoneyCategory.getCategory(row["category"]);
      cellItems.add(MoneyItem.from(row, category));
    }

    setState(() {
      isItemsLoaded = true;
    });
  }

  @override
  newItem(MoneyItem item) async {
    Database db = await DbHelper.database;
    await db.insert(
      DbTableName.moneyPitItems,
      item.toMap(exclude: ["id"]),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    loadItems();
  }

  @override
  editItem(MoneyItem item) async {
    if (item.id < 0) {
      newItem(item);
      return;
    }

    Database db = await DbHelper.database;
    await db.update(
      DbTableName.moneyPitItems,
      item.toMap(exclude: ["id", "cellid"]),
      where: "id = ?",
      whereArgs: [item.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    loadItems();
  }

  @override
  deleteItem(MoneyItem item) async {
    setState(() {
      isItemsLoaded = false;
    });

    Database db = await DbHelper.database;
    await db.delete(
      DbTableName.moneyPitItems,
      where: "id = ?",
      whereArgs: [item.id],
    );

    loadItems();
  }


  bool _isFilterSet() {
    return false;
  }

  List<MoneyItem> filterItems() {
    List<MoneyItem> filteredItems = [];

    bool catInFilter(MoneyCategory? category) {
      if (filter["cats"].isEmpty) return true;
      for (Map catMap in filter["cats"]) {
        if (category?.name == catMap["cat"]) return true;
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

    bool payMethodInFilter(String payMethod) {
      if (filter["paymethod"].isEmpty) return true;
      for (String item in filter["paymethod"]) {
        if (payMethod == item) return true;
      }
      return false;
    }

    for (MoneyItem item in cellItems) {
      if (
        catInFilter(item.category) &&
        dateInFilter(item.time) &&
        payMethodInFilter(item.payMethod)
      ) {
        filteredItems.add(item);
      }
    }

    filteredItems.sort(
      (i, j) => j.time.compareTo(i.time),
    );

    return filteredItems;
  }

  @override
  Widget buildItemTile(MoneyItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      horizontalTitleGap: 4,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MoneyDetailsPage(
            onEdit: editItem,
            item: item,
          ),
        ));
      },
      leading: Container(
        padding: const EdgeInsets.only(
          left: 15, right: 10,
        ),
        child: Icon(
          item.category?.icon,
          color: item.category?.color,
        ),
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
        DateTimeFormat.dateFormat(item.time),
      ),
      trailing: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            (item.isSpending ? "-" : "+") +
            currency +
            item.amount.toStringAsFixed(2),
            style: TextStyle(
              color: item.isSpending
                ? Palette.negative
                : Palette.positive,
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    key:     Key("delete-alert-${item.id}"),
                    title:   const Text("Delete Confirmation"),
                    content: Text("Do you want to delete \"${item.title}\"?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteItem(item);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Confirm"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  @override
  List<Widget> buildItemList() {
    List<Widget> items = [];
    for (MoneyItem item in filterItems()) {
      items.add(buildItemTile(item));
    }
    return items;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cell.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AnalysisPage(cellItems: cellItems),
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
                ? Palette.secondary
                : Colors.white,
            ),
            tooltip: "Filter and Sort",
          ),
        ],
      ),
      body: isItemsLoaded
        ? ListView(
            key: const Key("financelistview"),
            children: buildItemList(),
          )
        : const Center(child: CircularProgressIndicator()),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: FloatingActionButton(
              heroTag: "finance-income-button",
              backgroundColor: Palette.tertiary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.trending_up),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MoneyDetailsPage(
                    item: MoneyItem(
                      cellid: widget.cell.cellid, isSpending: false,
                    ),
                    onEdit: editItem,
                  )
                ));
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: FloatingActionButton(
              heroTag: "finance-spending-button",
              backgroundColor: Palette.secondary,
              foregroundColor: Palette.backgroundDark,
              child: const Icon(Icons.credit_card),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MoneyDetailsPage(
                    item: MoneyItem(
                      cellid: widget.cell.cellid, isSpending: true,
                    ),
                    onEdit: editItem,
                  )
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
