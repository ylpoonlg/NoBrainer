import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/ShopPage/ShopItem.dart';
import 'package:nobrainer/src/ShopPage/ShopItemDetails.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ShopPage extends StatefulWidget {
  final String uuid;

  ShopPage({required String this.uuid});

  @override
  State<StatefulWidget> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<dynamic> shopList = []; // Current status of the shopping list
  bool isShopListLoaded = false;

  String shopSortMode =
      shopSortModes[0]["value"]; // Sorting modes for shopping items
  String displayGroup = "all"; // group to display

  _ShopPageState() : super() {
    _loadShopList();
  }

  // Updates braincell content in database
  // Braincell must exist already in database.
  void _saveShopList() async {
    final Database db = await DbHelper.database;
    await db.update(
      "braincells",
      {
        'content': json.encode(shopList),
      },
      where: "uuid = ?",
      whereArgs: [widget.uuid],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    setState(() {
      isShopListLoaded = true;
    });
  }

  void _loadShopList() async {
    final Database db = await DbHelper.database;
    final List<dynamic> dbMap = await db.query(
      "braincells",
      where: "uuid = ?",
      whereArgs: [widget.uuid],
      distinct: true,
    );

    if (dbMap.isEmpty) {
      shopList = [];
    } else {
      shopList = json.decode(dbMap[0]["content"] ?? "[]");
    }

    setState(() {
      isShopListLoaded = true;
    });
  }

  void _addShopItem() {
    Map newItem = Map.from(defaultShopItem);
    newItem["id"] = "shop-item-" + shopList.length.toString();
    shopList.add(newItem);
    _saveShopList(); // Save to local storage first

    // Jump to directly to the detail page
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ShopItemDetails(
        onUpdate: _updateShopItem,
        data: newItem,
      ),
    ));
  }

  void _deleteShopItem(id) {
    shopList.removeWhere((item) {
      return item["id"] == id;
    });
    // Update id
    for (int i = 0; i < shopList.length; i++) {
      shopList[i]["id"] = "shop-item-" + i.toString();
    }
    _saveShopList();
  }

  void _clearBoughtItems() {
    shopList.removeWhere((item) {
      return item["status"] == true;
    });
    // Update id
    for (int i = 0; i < shopList.length; i++) {
      shopList[i]["id"] = "shop-item-" + i.toString();
    }
    _saveShopList();
  }

  void _updateShopItem(data) {
    for (int i = 0; i < shopList.length; i++) {
      if (shopList[i]["id"] == data["id"]) {
        shopList[i] = data;
        break;
      }
    }
    _saveShopList();
  }

  /// Sort the list according to the sort mode.
  ///
  /// Returns widgets of the shopping list.
  List<Widget> _getShopList() {
    List<Map> sortedList = List.from(shopList);

    // Sort items in ascending value
    sortedList.sort((i, j) {
      if (shopSortMode == "status") {
        // Put items that have not been bought at the front
        const Map<bool, int> statusValue = {
          false: 0,
          true: 1,
        };
        int a = statusValue[i["status"]] ?? 0;
        int b = statusValue[j["status"]] ?? 0;
        return a.compareTo(b);
      } // Default to item mode
      return i["title"].compareTo(j["title"]);
    });

    List<Widget> items = [];
    for (int i = 0; i < sortedList.length; i++) {
      items.add(ShopItem(
        key: Key("shopitem-" + const Uuid().v1()),
        data: sortedList[i],
        onDelete: _deleteShopItem,
        onUpdate: _updateShopItem,
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Shopping List"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  key: const Key("clear-bought-items"),
                  title: const Text("Delete Confirmation"),
                  content: const Text(
                      "Are you sure you want to remove all the checked items?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          _clearBoughtItems();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Confirm")),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.clear_all),
          ),
          PopupMenuButton(
            initialValue: shopSortMode,
            onSelected: (value) {
              setState(() {
                shopSortMode = value.toString();
              });
            },
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext context) {
              return shopSortModes.map((Map mode) {
                return PopupMenuItem<String>(
                    value: mode["value"], child: Text(mode["label"]));
              }).toList();
            },
          ),
        ],
      ),
      body: isShopListLoaded
          ? ListView(
              key: const Key("shoplistview"),
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
        onPressed: _addShopItem,
      ),
    );
  }
}
