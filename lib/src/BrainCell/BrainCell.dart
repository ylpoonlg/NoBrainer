import 'package:flutter/material.dart';
import 'package:nobrainer/src/FinancePage/FinancePage.dart';
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
  late bool   isFolder;
  late int    cellid;
  late String title;
  late String type;
  late Color  color;
  late Map    settings;

  BrainCell({
    required this.title,
    this.cellid   = -1,
    this.type     = BrainCellType.none,
    this.color    = Colors.grey,
    this.isFolder = false,
    this.settings = const {},
  });
  

  StatefulWidget getPage() {
    switch (type) {
      case BrainCellType.todoList:
        return TodoPage(cellid: cellid);
      case BrainCellType.shopList:
        return ShopPage(cellid: cellid);
      case BrainCellType.moneyPit:
        return FinancePage(uuid: cellid.toString());
      default:
        return TodoPage(cellid: cellid);
    }
  }
}
