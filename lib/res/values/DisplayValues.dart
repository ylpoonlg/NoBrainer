import 'package:nobrainer/res/Theme/AppTheme.dart';

/*
  This file contains item values for menus and displays
*/

/// Convert type value to a label text
Map<String, String> typeLabel = {
  "todolist": "Todo List",
  "shoplist": "Shopping List",
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
