import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';
import 'package:sqflite/sqflite.dart';

class Shops {
  static Future<List<String>> getShops() async {
    Database  db   = DbHelper.database;
    List<Map> rows = await db.query(
      DbTableName.shops,
    );
    return rows.map((row) => row["name"].toString()).toList();
  }

  static Future<void> newShop(String shop) async {
    Database db = DbHelper.database;
    await db.insert(
      DbTableName.shops,
      {
        "name": shop,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteShop(String shop) async {
    Database db = DbHelper.database;
    await db.delete(
      DbTableName.shops,
      where:     "name = ?",
      whereArgs: [shop],
    );
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
  State<StatefulWidget> createState() => _ShopsListState();
}

class _ShopsListState extends State<ShopsList> {
  late List<String> selected = [];
  List<String> shops = [];
  bool isLoaded = false;

  _ShopsListState() {
    _loadShops();
  }

  _loadShops() async {
    shops = await Shops.getShops();
    setState(() {
      isLoaded = true;
    });
  }

  _newShop(String shop) async {
    await Shops.newShop(shop);
    _loadShops();
  }

  _deleteShop(String shop) async {
    setState(() {
      isLoaded = false;
    });
    await Shops.deleteShop(shop);
    await _loadShops();
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
              _newShop(newShopName);
              Navigator.of(context).pop();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  onDeleteShop(String shop) async {
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
              _deleteShop(shop);
              Navigator.of(context).pop();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  @override
  Widget build(context) {
    if (isLoaded) {
      return Scrollbar(
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
            ...shops
                .map(
                  (shop) => ListTile(
                    leading: Checkbox(
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
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
