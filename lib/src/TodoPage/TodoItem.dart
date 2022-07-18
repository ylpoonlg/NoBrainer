import 'package:flutter/material.dart';

class TodoItem {
  late int      id;
  late int      cellid;
  late String   title;
  late String   desc;
  late String   status;
  late DateTime deadline;
  late int      notifytime;

  TodoItem({
    this.id         = -1,
    this.cellid     = -1,
    this.title      = "",
    this.desc       = "",
    this.status     = TodoStatus.todo,
    this.notifytime = -1,
    DateTime? deadline,
  }) {
    this.deadline = deadline ?? DateTime.now();
  }

  static TodoItem from(Map row) {
    return TodoItem(
      id:         row["id"],
      cellid:     row["cellid"],
      title:      row["title"],
      desc:       row["desc"],
      status:     row["status"],
      deadline:   DateTime.parse(row["deadline"]),
      notifytime: row["notifytime"],
    );
  }

  TodoItem clone() {
    return TodoItem(
      id:         id,
      cellid:     cellid,
      title:      title,
      desc:       desc,
      status:     status,
      deadline:   deadline,
      notifytime: notifytime,
    );
  }

  Map<String, Object?> toMap({List<String> exclude = const []}) {
    Map<String, Object?> map = {
      "id":         id,
      "cellid":     cellid,
      "title":      title,
      "desc":       desc,
      "status":     status,
      "deadline":   deadline.toString(),
      "notifytime": notifytime,
    };
    exclude.forEach((key) {
      map.remove(key);
    });
    return map;
  }
}

class TodoStatus {
  static const String todo    = "todo";
  static const String urgent  = "urgent";
  static const String ongoing = "ongoing";
  static const String done    = "done";

  static String getStatusLabel(String status) {
    switch (status) {
      case TodoStatus.urgent:
        return "Urgent";
      case TodoStatus.ongoing:
        return "Ongoing";
      case TodoStatus.done:
        return "Done";
      default:
        return "Todo";
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case TodoStatus.todo:
        return const Color(0xff982626);
      case TodoStatus.urgent:
        return const Color(0xffda66fa);
      case TodoStatus.ongoing:
        return const Color(0xffffb82d);
      case TodoStatus.done:
        return const Color(0xff4cd44a);
      default:
        return const Color(0xffaaaaaa);
    }
  }

  static int getStatusOrder(String status) {
    switch (status) {
      case TodoStatus.todo:
        return 1;
      case TodoStatus.urgent:
        return 2;
      case TodoStatus.ongoing:
        return 3;
      case TodoStatus.done:
        return 4;
      default:
        return 5;
    }
  }

  static int compare(String i, String j) {
    return TodoStatus.getStatusOrder(i).compareTo(
      TodoStatus.getStatusOrder(j)
    );
  }
}

class TodoItemSort {
  static const String deadline = "deadline";
  static const String status   = "status";

  static String getSortModeLabel(String sort) {
    switch (sort) {
      case TodoItemSort.deadline:
        return "Deadline";
      case TodoItemSort.status:
        return "Status";
      default:
        return "Error";
    }
  }
}
