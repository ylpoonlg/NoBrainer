import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

/*
  This file contains item values for menus and displays
*/

/// Convert type value to a label text
Map<String, String> typeLabel = {
  "todolist": "Todo List",
  "shoplist": "Shopping List",
  "finance": "Finance",
  "select": "Select a type",
};

/// Todo List Sorting Modes
List<Map> todoSortModes = [
  {
    "label": "Deadline",
    "value": "deadline",
  },
  {
    "label": "Status",
    "value": "status",
  },
];

/// Shopping List Sorting Modes
List<Map> shopSortModes = [
  {
    "label": "Status",
    "value": "status",
  },
  {
    "label": "Item",
    "value": "item",
  },
  {
    "label": "Shop",
    "value": "shop",
  },
];

/// Define Todo List Status
List todoStatus = [
  {
    "label": "Urgent",
    "value": "urgent",
    "color": AppTheme.color["purple"],
  },
  {
    "label": "Todo",
    "value": "todo",
    "color": AppTheme.color["red"],
  },
  {
    "label": "Ongoing",
    "value": "ongoing",
    "color": AppTheme.color["yellow"],
  },
  {
    "label": "Completed",
    "value": "completed",
    "color": AppTheme.color["green"],
  },
];

/// Default finance categories
final List<Map> defaultCategories = [
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

const Map<String, String> currencySymbol = {
  "dollar": "\$",
  "pound": "£",
  "euro": "€",
  "yen": "¥",
  "ruble": "₽",
};
