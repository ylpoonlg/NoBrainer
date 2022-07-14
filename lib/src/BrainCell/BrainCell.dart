import 'package:flutter/material.dart';
import 'package:nobrainer/src/FinancePage/FinancePage.dart';
import 'package:nobrainer/src/ShopPage/ShopPage.dart';
import 'package:nobrainer/src/TodoPage/TodoPage.dart';

class BrainCellType {
  static const String todoList = "todolist";
  static const String shopList = "shoplist";
  static const String moneyPit = "moneypit";
  static const String none = "none";
}

class BrainCell {
  bool isFolder = false;
  int cellid = -1;
  String title;
  String type = BrainCellType.none;
  Color color = Colors.grey;
  Map settings = {};

  BrainCell({
    required this.title,
    this.cellid = -1,
    this.type = BrainCellType.none,
    this.color = Colors.grey,
    this.isFolder = false,
    this.settings = const {},
  });
  

  StatefulWidget getPage() {
    switch (type) {
      case BrainCellType.todoList:
        return TodoPage(uuid: cellid.toString());
      case BrainCellType.shopList:
        return ShopPage(uuid: cellid.toString());
      case BrainCellType.moneyPit:
        return FinancePage(uuid: cellid.toString());
      default:
        return TodoPage(uuid: cellid.toString(),);
    }
  }
}
