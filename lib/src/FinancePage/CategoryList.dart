import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:sqflite/sqflite.dart';

class CategoryList extends StatefulWidget {
  Function(Map) onSelect;

  CategoryList({Key? key, required this.onSelect});
  @override
  State<StatefulWidget> createState() => CategoryListState();
}

class CategoryListState extends State<CategoryList> {
  static List<Map> categories = [];
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
    final List customCat = json.decode(dbMap[0]["value"]).toList();
    debugPrint(customCat.toString());

    List<Map> categories = [
      {
        "cat": "General",
        "icon": Icons.group_work,
        "color": AppTheme.color["gray"],
      },
      {
        "cat": "Shopping",
        "icon": Icons.shop,
        "color": AppTheme.color["cyan"],
      },
      {
        "cat": "Restaurant",
        "icon": Icons.food_bank,
        "color": AppTheme.color["orange"],
      },
      {
        "cat": "Groceries",
        "icon": Icons.apple,
        "color": AppTheme.color["red"],
      },
      {
        "cat": "Transport",
        "icon": Icons.train,
        "color": AppTheme.color["green"],
      },
      {
        "cat": "Friends",
        "icon": Icons.people,
        "color": AppTheme.color["yellow"],
      },
      {
        "cat": "Bills",
        "icon": Icons.receipt,
        "color": AppTheme.color["purple"],
      },
    ];

    categories.addAll(customCat.map((cat) => {
          "cat": cat["cat"],
          "icon": AppTheme.icon[cat["icon"]],
          "color": AppTheme.mapToColor(cat["color"]),
        }));

    CategoryListState.categories = categories;
    isCategoriesLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return isCategoriesLoaded
        ? ListView(
            children: categories.map((cat) {
              return ListTile(
                onTap: () {
                  widget.onSelect(cat);
                },
                leading: Icon(
                  cat["icon"],
                  color: cat["color"],
                ),
                title: Text(cat["cat"]),
              );
            }).toList(),
          )
        : Center(
            child: CircularProgressIndicator(
              color: AppTheme.color["accent-primary"],
            ),
          );
  }
}
