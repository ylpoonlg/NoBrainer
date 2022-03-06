import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';
import 'package:sqflite/sqflite.dart';

class Shops {
  static List<String> shops = [];

  static getShops() async {
    final Database db = await DbHelper.database;
    dynamic dbMap = await db.query(
      "settings",
      where: "name = ?",
      whereArgs: ["shoplist-shops"],
    );
    if (dbMap.isEmpty) {
      shops = [];
    } else {
      shops = List<String>.from(json.decode(dbMap[0]["value"]).toList());
    }
  }

  static saveShop() async {
    final Database db = await DbHelper.database;
    await db.execute(
      "INSERT OR REPLACE INTO settings (name, value) "
      "VALUES (?, ?)",
      ["shoplist-shops", json.encode(shops)],
    );
  }

  static addShop(String methodName) {
    shops.add(methodName);
    saveShop();
  }

  static deleteShop(String methodName) {
    shops.removeWhere((item) => item == methodName);
    saveShop();
  }
}

class ShopsList extends StatefulWidget {
  final List<String> selected;
  final Function(List<String>) onChanged;

  const ShopsList({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShopsListState(selected);
}

class _ShopsListState extends State<ShopsList> {
  List<String> selected = [];
  bool isLoaded = false;

  _ShopsListState(this.selected) {
    loadShops();
  }

  loadShops() async {
    await Shops.getShops();
    setState(() {
      isLoaded = true;
    });
  }

  addShop(String methodName) async {
    setState(() {
      isLoaded = false;
    });
    await Shops.addShop(methodName);
    await loadShops();
  }

  deleteShop(String methodName) async {
    await Shops.deleteShop(methodName);
    await loadShops();
  }

  onNewShop() {
    String newShopName = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Shop"),
        content: TextField(
          controller: TextEditor.getController(newShopName),
          onChanged: (value) {
            newShopName = value;
          },
          decoration: const InputDecoration(
            labelText: "Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              addShop(newShopName);
              Navigator.of(context).pop();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  onDeleteShop(String methodName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure to delete this shop?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                deleteShop(methodName);
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
          ]),
    );
  }

  @override
  Widget build(context) {
    return isLoaded
        ? Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView(
              children: [
                ListTile(
                    title: const Text("Clear"),
                    onTap: () {
                      setState(() {
                        selected = [];
                        widget.onChanged(selected);
                      });
                    }),
                ...Shops.shops
                    .map(
                      (shop) => ListTile(
                        leading: Checkbox(
                          activeColor: AppTheme.color["accent-primary"],
                          checkColor: AppTheme.color["white"],
                          value: selected.contains(shop),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selected.add(shop);
                              } else {
                                selected.remove(shop);
                              }
                              widget.onChanged(selected);
                            });
                          },
                        ),
                        title: Text(shop),
                        trailing: IconButton(
                          onPressed: () {
                            onDeleteShop(shop);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                    )
                    .toList(),
                ListTile(
                  onTap: onNewShop,
                  leading: const Icon(Icons.add),
                  title: const Text("New Shop"),
                ),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
