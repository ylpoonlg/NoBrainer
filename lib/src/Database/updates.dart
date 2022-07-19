import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';
import 'package:nobrainer/src/Theme/custom_icons.dart';
import 'package:nobrainer/src/TodoPage/TodoItem.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbUpdate {
  static Future<void> createTables(Database db) async {
    for (String table in dbTables) {
      await db.execute("CREATE TABLE IF NOT EXISTS $table;");
    }
  }

  static Future<void> updateDbVersion4(Database db) async {
    await createTables(db);

    String oldPath = join(await getDatabasesPath(), "nobrainer.db");
    if (await databaseExists(oldPath)) {
      debugPrint(" => Old database found at $oldPath");
      debugPrint(" => Migrating to new database...");

      Database oldDb = await openDatabase(oldPath);

      // Do migrations
      List<Map> braincells = await oldDb.query("braincells");
      for (Map row in braincells) {
        Map props = json.decode(row["props"]);

        String type = props["type"];
        if (type == "todolist") {
          type = BrainCellType.todoList;
        } else if (type == "shoplist") {
          type = BrainCellType.shopList;
        } else if (type == "finance") {
          type = BrainCellType.moneyPit;
        } else {
          type = BrainCellType.none;
        }

        await db.insert(
          DbTableName.braincells,
          {
            "name":     props["name"],
            "type":     type,
            "color":    Color.fromRGBO(
              props["color"]["red"],
              props["color"]["green"],
              props["color"]["blue"],
              props["color"]["opacity"],
            ).value,
            "settings": {}.toString(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        int cellid = -1;
        List<Map> rowid = await db.rawQuery("SELECT last_insert_rowid();");
        if (rowid.isNotEmpty) {
          List<Map> lastRow = await db.query(
            DbTableName.braincells,
            where: "rowid = ?", whereArgs: [rowid[0]["last_insert_rowid()"]],
          );
          cellid = lastRow[0]["cellid"];
        }

        await db.insert(
          DbTableName.cellFolders,
          {
            "cellid":  cellid,
            "orderid": row["orderIndex"],
            "name":    props["name"],
            "parent":  0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );


        // Content
        List<dynamic> cellItems = json.decode(row["content"]);
        for (dynamic item in cellItems) {
          switch (type) {
            case BrainCellType.todoList:
              String status = item["status"];
              if (status == "urgent") {
                status = TodoStatus.todo;
              } else if (status == "ongoing") {
                status = TodoStatus.ongoing;
              } else if (status == "completed") {
                status = TodoStatus.done;
              } else {
                status = TodoStatus.todo;
              }

              await db.insert(
                DbTableName.todoItems,
                {
                  "cellid":     cellid,
                  "title" :     item["title"],
                  "desc":       item["desc"],
                  "status":     status,
                  "deadline":   item["deadline"],
                  "notifytime": -1,
                },
                conflictAlgorithm: ConflictAlgorithm.ignore,
              );
              break;
            case BrainCellType.shopList:
              await db.insert(
                DbTableName.shopItems,
                {
                  "cellid":   cellid,
                  "title" :   item["title"],
                  "desc":     item["desc"],
                  "status":   item["status"] ? 1 : 0,
                  "price":    item["price"],
                  "quantity": item["quantity"],
                  "shops":    json.encode(item["shops"]),
                },
                conflictAlgorithm: ConflictAlgorithm.ignore,
              );
              break;
            case BrainCellType.moneyPit:
              await db.insert(
                DbTableName.moneyPitItems,
                {
                  "cellid":     cellid,
                  "title" :     item["title"],
                  "desc":       item["desc"],
                  "amount":     item["amount"],
                  "isspending": item["spending"] ? 1 : 0,
                  "paymethod":  item["paymethod"] ?? "",
                  "category":   item["cat"],
                  "time":       item["time"],
                },
                conflictAlgorithm: ConflictAlgorithm.ignore,
              );
              break;
          }
        }
      }


      // Settings
      List<Map> themeRow = await oldDb.query(
        "settings",
        where: "name = ?",
        whereArgs: ["theme"],
      );
      if (themeRow.isNotEmpty) {
        await db.insert(
          DbTableName.settings,
          {
            "name":  "themeName",
            "value": themeRow[0]["value"],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      List<Map> currencyRow = await oldDb.query(
        "settings",
        where: "name = ?",
        whereArgs: ["currency"],
      );
      if (currencyRow.isNotEmpty) {
        await db.insert(
          DbTableName.settings,
          {
            "name":  "currency",
            "value": currencyRow[0]["value"],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }


      // Money Categories
      List<Map> categoryRow = await oldDb.query(
        "settings",
        where: "name = ?",
        whereArgs: ["finance-custom-cat"],
      );
      if (categoryRow.isNotEmpty) {
        List<MoneyCategory> categories = [];
        for (Map catMap in _defaultCategories) {
          categories.add(MoneyCategory(
            name:  catMap["cat"],
            icon:  catMap["icon"],
            color: catMap["color"],
          ));
        }

        List customCat = json.decode(categoryRow[0]["value"]);
        for (dynamic cat in customCat) {
          categories.add(MoneyCategory(
            name:  cat["cat"],
            icon:  CustomIcons.getIcon(cat["icon"]),
            color: Color.fromRGBO(
              cat["color"]["red"],
              cat["color"]["green"],
              cat["color"]["blue"],
              cat["color"]["opacity"],
            ),
          ));
        }

        for (MoneyCategory cat in categories) {
          await db.insert(
            DbTableName.moneyCategories,
            {
              "name":  cat.name,
              "icon":  CustomIcons.getIconString(cat.icon),
              "color": cat.color.value,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }


      // PayMethod
      List<Map> paymethodRow = await oldDb.query(
        "settings",
        where: "name = ?",
        whereArgs: ["finance-paymethods"],
      );
      if (paymethodRow.isNotEmpty) {
        List<dynamic> payMethods = json.decode(paymethodRow[0]["value"]);
        for (dynamic payMethod in payMethods) {
          await db.insert(
            DbTableName.payMethods,
            {
              "name": payMethod.toString(),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }

      // Shops
      List<Map> shopsRow = await oldDb.query(
        "settings",
        where: "name = ?",
        whereArgs: ["shoplist-shops"],
      );
      if (shopsRow.isNotEmpty) {
        List<dynamic> shops = json.decode(shopsRow[0]["value"]);
        for (dynamic shop in shops) {
          await db.insert(
            DbTableName.shops,
            {
              "name": shop.toString(),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
      
      // Delete old database
      await oldDb.close();
      await deleteDatabase(oldPath);
      debugPrint(" => Deleted old database");
    }
  }
}

final List<Map> _defaultCategories = [
  {
    "cat":   "General",
    "icon":  Icons.interests,
    "color": const Color(0xffaaaaaa),
  },
  {
    "cat": "Shopping",
    "icon": Icons.local_mall,
    "color": const Color(0xff00ffff),
  },
  {
    "cat": "Restaurant",
    "icon": Icons.food_bank,
    "color": const Color(0xffff9000),
  },
  {
    "cat": "Groceries",
    "icon": Icons.local_grocery_store,
    "color": const Color(0xffff0000),
  },
  {
    "cat": "Transport",
    "icon": Icons.train,
    "color": const Color(0xff22ff55),
  },
  {
    "cat": "Friends",
    "icon": Icons.people,
    "color": const Color(0xffaaaa00),
  },
  {
    "cat": "Bills",
    "icon": Icons.receipt,
    "color": const Color(0xffff99ff),
  },
];
