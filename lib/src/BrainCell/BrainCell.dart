import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/MoneyPage/MoneyPage.dart';
import 'package:nobrainer/src/ShopPage/ShopPage.dart';
import 'package:nobrainer/src/TodoPage/TodoPage.dart';

class BrainCellType {
  static const String todoList = "todolist";
  static const String shopList = "shoplist";
  static const String moneyPit = "moneypit";
  static const String none     = "none";

  static String getBrainCellTypeLabel(String type) {
    switch (type) {
      case BrainCellType.todoList:
        return "Todo List";
      case BrainCellType.shopList:
        return "Shopping List";
      case BrainCellType.moneyPit:
        return "Money Pit";
      default:
        return "Error";
    }
  }
}

class BrainCell {
  late bool   isFolder;  // true if cellid == -1
  late int    folderId;
  late int    cellid;
  late String title;
  late String type;
  late Color  color;
  late Map    settings;

  BrainCell({
    required this.title,
    this.cellid   = -1,
    this.folderId = -1,
    this.type     = BrainCellType.none,
    this.color    = Colors.grey,
    this.isFolder = false,
    this.settings = const {},
  });
  

  Widget? getPage() {
    switch (type) {
      case BrainCellType.todoList:
        return TodoPage(cell: this);
      case BrainCellType.shopList:
        return ShopPage(cell: this);
      case BrainCellType.moneyPit:
        return MoneyPage(cell: this);
      default:
        return null;
    }
  }

  Map<String, Object?> toBrainCellsMap({List<String> exclude = const []}) {
    Map<String, Object?> map = {
      "cellid":   cellid,
      "name":     title,
      "type":     type,
      "color":    color.value,
      "settings": json.encode(settings),
    };
    exclude.forEach((key) {
      map.remove(key);
    });
    return map;
  }
}
