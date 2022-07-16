import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/Theme/custom_icons.dart';
import 'package:sqflite/sqflite.dart';

class MoneyCategory {
  late String    name;
  late IconData? icon;
  late Color     color;

  MoneyCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static Future<List<MoneyCategory>> getCategories() async {
    Database db = await DbHelper.database;
    List<Map> rows = await db.query(DbTableName.moneyCategories);
    List<MoneyCategory> result = [];
    result = rows.map((row) => MoneyCategory(
      name:  row["name"],
      icon:  CustomIcons.getIcon(row["icon"]),
      color: Color(row["color"]),
    )).toList();
    return result;
  }

  static Future<MoneyCategory?> getCategory(String? name) async {
    if (name == null) return null;
    Database db = await DbHelper.database;
    List<Map> rows = await db.query(
      DbTableName.moneyCategories,
      where: "name = ?",
      whereArgs: [name],
    );
    if (rows.isNotEmpty) {
      Map row = rows[0];
      return MoneyCategory(
        name: row["name"],
        icon:  CustomIcons.getIcon(row["icon"]),
        color: Color(row["color"]),
      );
    }
    return null;
  }

  static Future<void> newCategory(MoneyCategory category) async {
    Database db = await DbHelper.database;
    await db.insert(
      DbTableName.moneyCategories,
      {
        "name":  category.name,
        "icon":  CustomIcons.getIconString(category.icon),
        "color": category.color.value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteCategory(MoneyCategory category) async {
    Database db = await DbHelper.database;
    await db.delete(
      DbTableName.moneyCategories,
      where: "name = ?",
      whereArgs: [category.name],
    );
  }
}

