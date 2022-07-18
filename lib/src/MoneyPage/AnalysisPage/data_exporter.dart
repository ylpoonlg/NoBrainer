import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';

class DataExporter {
  Future<void> exportData({
    required List<MoneyItem>       cellItems,
    required Function(String path) onSuccess,
    Function(Object? error)?       onFailed,
  }) async {
    if (!await DbHelper.checkPermissions()) return;

    List<List<dynamic>> rows = [];

    rows.add([
      "title",
      "amount",
      "type",
      "paymethod",
      "category",
      "time",
      "description",
    ]);
    for (MoneyItem item in cellItems) {
      rows.add([
        item.title,
        item.amount,
        item.isSpending ? "expense" : "income",
        item.payMethod,
        item.category?.name ?? "",
        item.time.toString(),
        item.desc,
      ]);
    }

    try {
      String csv = const ListToCsvConverter().convert(rows);
      //String dir = (await ExternalPath.getExternalStorageDirectories())[0];
      String dir = "/storage/emulated/0/";
      File file = File(dir + "/NoBrainer/finance_data.csv");
      debugPrint(file.path);
      file.createSync(recursive: true);
      file.writeAsString(csv);

      onSuccess(file.path);
    } catch (e) {
      onFailed?.call(e);
    }
  }
}
