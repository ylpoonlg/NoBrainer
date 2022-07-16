import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/BrainCell/CellPage.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/MoneyPage/FinanceFilter.dart';
import 'package:nobrainer/src/MoneyPage/MoneyDetailsPage.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/MoneyPage/AnalysisPage.dart';
import 'package:nobrainer/src/MoneyPage/CategoryList.dart';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

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

  Map filter = {
    "cats": [],
    "paymethod": [],
    "date-from": null,
    "date-to": null,
  };

  List<Map> categories = [];

  _MoneyPageState() {
    loadItems();
  }

  @override
  loadItems() async {
    Database db = await DbHelper.database;
    await CategoryListState.getCategories();

    setState(() {
      isItemsLoaded = true;
    });
  }

  @override
  newItem(MoneyItem item) {

  }

  @override
  editItem(MoneyItem item) async {
    newItem(item);
  }

  @override
  deleteItem(MoneyItem item) async {
  }


  bool _isFilterSet() {
    return false;
  }

  List<MoneyItem> filterItems() {
    List<MoneyItem> filteredItems = [];

    bool catInFilter(String cat) {
      if (filter["cats"].isEmpty) return true;
      for (Map catMap in filter["cats"]) {
        if (cat == catMap["cat"]) return true;
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

    filteredItems.sort(
      (i, j) => j.time.compareTo(i.time),
    );

    return filteredItems;
  }

  @override
  Widget buildItemTile(MoneyItem item) {
    return ListTile(
      leading: const Icon(Icons.currency_bitcoin),
      title: Text(item.title),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cell.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AnalysisPage(financeList: const []),
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
