import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/FinancePage/NewCategory.dart';
import 'package:sqflite/sqflite.dart';

class CategoryList extends StatefulWidget {
  Function(Map?) onSelect;

  CategoryList({Key? key, required this.onSelect});
  @override
  State<StatefulWidget> createState() => CategoryListState();
}

class CategoryListState extends State<CategoryList> {
  static List<Map> categories = [];
  static List<Map> _customCat = [];
  static bool isCategoriesLoaded = false;

  CategoryListState() : super() {
    getCategories();
  }

  static getCategories() async {
    final Database db = await DbHelper.database;
    dynamic dbMap = await db.query(
      "settings",
      where: "name = ?",
      whereArgs: ["finance-custom-cat"],
    );
    final List stringCat = json.decode(dbMap[0]["value"]).toList();
    CategoryListState._customCat = stringCat
        .map((cat) => {
              "cat": cat["cat"],
              "icon": AppTheme.icon[cat["icon"]],
              "icon_string": cat["icon"],
              "color": AppTheme.mapToColor(cat["color"]),
            })
        .toList();

    List<Map> categories = List.from(defaultCategories);
    categories.addAll(CategoryListState._customCat);

    CategoryListState.categories = categories;
    isCategoriesLoaded = true;
  }

  saveCategories() async {
    setState(() {
      isCategoriesLoaded = false;
    });

    final Database db = await DbHelper.database;
    await db.update(
      "settings",
      {
        "value": json.encode(_customCat
            .map((cat) => {
                  "cat": cat["cat"],
                  "icon": cat["icon_string"],
                  "color": AppTheme.colorToMap(cat["color"]),
                })
            .toList()),
      },
      where: "name = ?",
      whereArgs: ["finance-custom-cat"],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    setState(() {
      isCategoriesLoaded = true;
    });
  }

  /// Prompt user to create a new category and add to both local list and database
  _onAddCat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewCategory((newCat) {
          categories.add(newCat);
          _customCat.add(newCat);
          saveCategories();
        }),
      ),
    );
  }

  /// Delete Custom Categories
  _onDeleteCat(String catname) {
    categories.removeWhere((cat) => cat["cat"] == catname);
    _customCat.removeWhere((cat) => cat["cat"] == catname);
    saveCategories();
  }

  _getListTiles() {
    const listTilePadding = EdgeInsets.symmetric(horizontal: 0);

    final listTiles = categories.map((cat) {
      return ListTile(
        contentPadding: listTilePadding,
        onTap: () {
          widget.onSelect(cat);
        },
        leading: Icon(
          cat["icon"],
          color: cat["color"],
        ),
        title: Text(cat["cat"]),
        trailing: CategoryListState._customCat.indexWhere(
                  (custom) => custom["cat"] == cat["cat"],
                ) !=
                -1
            ? IconButton(
                onPressed: () {
                  _onDeleteCat(cat["cat"]);
                },
                icon: const Icon(Icons.delete),
              )
            : Container(
                width: 0,
                height: 0,
              ),
      );
    }).toList();
    listTiles.add(
      ListTile(
        contentPadding: listTilePadding,
        title: TextButton(
          onPressed: _onAddCat,
          child: const Text("+ Add a custom category"),
        ),
      ),
    );

    listTiles.insert(
      0,
      ListTile(
        onTap: () {
          widget.onSelect(null);
        },
        title: const Text("None"),
      ),
    );
    return listTiles;
  }

  @override
  Widget build(BuildContext context) {
    return isCategoriesLoaded
        ? Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView(children: _getListTiles()),
          )
        : Center(
            child: CircularProgressIndicator(
              color: AppTheme.color["accent-primary"],
            ),
          );
  }
}
