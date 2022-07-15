@Deprecated("Use class instead of map")

import 'package:flutter/material.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';

/*
  This file contains item values for menus and displays
*/

/// Default finance categories
final List<Map> defaultCategories = [
  {
    "cat": "General",
    "icon": Icons.interests,
    "color": AppTheme.color["light-gray"],
  },
  {
    "cat": "Shopping",
    "icon": Icons.local_mall,
    "color": AppTheme.color["cyan"],
  },
  {
    "cat": "Restaurant",
    "icon": Icons.food_bank,
    "color": AppTheme.color["orange"],
  },
  {
    "cat": "Groceries",
    "icon": Icons.local_grocery_store,
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

/// Todo List Sorting Modes
List<Map> financeAnalyzeScope = [
  {
    "label": "Week",
    "value": "week",
  },
  {
    "label": "Month",
    "value": "month",
  },
  {
    "label": "Year",
    "value": "year",
  },
];
