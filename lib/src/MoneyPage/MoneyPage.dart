import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/BrainCell/CellPage.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/MoneyPage/Currencies.dart';
import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';
import 'package:nobrainer/src/MoneyPage/MoneyDetailsPage.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';
import 'package:nobrainer/src/MoneyPage/money_filter_page.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/MoneyPage/AnalysisPage/analysis_page.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';
import 'package:nobrainer/src/Widgets/filter_panel.dart';

import 'package:sqflite/sqflite.dart';

class MoneyPage extends StatefulWidget {
  final BrainCell cell;

  const MoneyPage({required this.cell, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> implements CellPage<MoneyItem> {
  @override
  List<MoneyItem> cellItems          = [];
  @override
  bool            isItemsLoaded      = false;

  String          currency           = "\$";
  MoneyFilter     filter             = MoneyFilter();
  bool            isFilterPanelShown = false;

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
    return filter.categories.isNotEmpty || filter.payMethods.isNotEmpty ||
      filter.dateFrom != null || filter.dateTo != null;
  }

  List<MoneyItem> filterItems() {
    List<MoneyItem> filteredItems = [];

    bool catInFilter(MoneyCategory? category) {
      if (filter.categories.isEmpty) return true;
      for (String catName in filter.categories) {
        if (category?.name == catName) return true;
      }
      return false;
    }

    bool dateInFilter(DateTime dt) {
      if (filter.dateFrom != null) {
        if (dt.compareTo(filter.dateFrom!) < 0) return false;
      }

      if (filter.dateTo != null) {
        if (dt.compareTo(filter.dateTo!.add(const Duration(days: 1))) > 0) {
          return false;
        }
      }
      return true;
    }

    bool payMethodInFilter(String payMethod) {
      if (filter.payMethods.isEmpty) return true;
      for (String item in filter.payMethods) {
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cell.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFilterPanelShown = !isFilterPanelShown;
              });
            },
            icon: Icon(
              Icons.filter_list,
              color: _isFilterSet()
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: "Filter and Sort",
          ),
        ],
      ),

      body: Stack(
        children: [
          Container(
            child: isItemsLoaded
            ? ListView(
                key: const Key("financelistview"),
                padding: const EdgeInsets.only(bottom: 120),
                children: <Widget>[
                  _isFilterSet()
                    ? MaterialButton(
                      child: const Text("Clear Filter"),
                      onPressed: () {
                        setState(() {
                          filter = MoneyFilter();
                        });
                      },
                    ) : const SizedBox()
                ] + buildItemList(),
              )
            : const Center(child: CircularProgressIndicator()),
          ),

          GestureDetector(
            onTap: isFilterPanelShown
              ? () {
                setState(() {
                  isFilterPanelShown = false;
                });
              } : null,
            onVerticalDragDown: isFilterPanelShown
              ? (_) {
                setState(() {
                  isFilterPanelShown = false;
                });
              } : null,
            child: isFilterPanelShown
              ? Container(color: Colors.black.withOpacity(0.4))
              : null,
          ),

          Positioned(
            bottom: 0,
            child: FilterPanel(
              isShown: isFilterPanelShown,
              child: MoneyFilterPage(
                filter: filter,
                onApply: (newFilter) {
                  setState(() {
                    filter = newFilter;
                    isFilterPanelShown = false;
                  });
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isFilterPanelShown
        ? Container()
        : Container(
          width: screenWidth,
          margin: const EdgeInsets.only(bottom: 20),
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.spaceEvenly,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              SizedBox(
                width:  screenWidth * 0.3,
                height: 60,
                child:  ElevatedButton.icon(
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
                  icon:  const Icon(Ionicons.log_in_outline),
                  label: const Text("Income"),
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Palette.positive
                    ),
                    foregroundColor: MaterialStatePropertyAll(
                      Palette.foregroundDark
                    ),
                  ),
                ),
              ),
              Container(
                width:  min(screenWidth * 0.2, 60),
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  )],
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                child:  FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AnalysisPage(
                        cell:      widget.cell,
                        cellItems: cellItems,
                      ),
                    ));
                  },
                  child:  const Icon(Ionicons.analytics_outline),
                  shape: const CircleBorder(),
                ),
              ),
              SizedBox(
                width:  screenWidth * 0.3,
                height: 60,
                child:  ElevatedButton.icon(
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
                  icon:  const Icon(Ionicons.log_out_outline),
                  label: const Text("Expense"),
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Palette.negative
                    ),
                    foregroundColor: MaterialStatePropertyAll(
                      Palette.foregroundDark
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
