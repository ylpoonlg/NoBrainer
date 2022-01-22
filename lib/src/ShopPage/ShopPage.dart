import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/ShopPage/ShopItem.dart';
import 'package:nobrainer/src/ShopPage/ShopItemDetails.dart';
import 'package:sqflite/sqflite.dart';

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
    newItem["deadline"] = DateTime.now().toString();
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
    _saveShopList();
  }

  void _updateShopItem(data) {
    for (int i = 0; i < shopList.length; i++) {
      if (shopList[i]["id"] == data["id"]) {
        shopList[i] = data;
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
      } else if (shopSortMode == "shop") {
        return i["shop"].compareTo(j["shop"]);
      }
      // Default to item mode
      return i["title"].compareTo(j["title"]);
    });

    List<Widget> items = [];
    for (int i = 0; i < sortedList.length; i++) {
      items.add(ShopItem(
        key: Key("shopitem-" + sortedList[i]["id"]),
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
