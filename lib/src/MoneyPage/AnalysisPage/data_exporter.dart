import 'dart:io';

import 'package:csv/csv.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';

class DataExporter {
  Future<void> exportData({
    required BrainCell             cell,
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
      String     csv  = const ListToCsvConverter().convert(rows);
      String     dir  = DbHelper.dbPath + "MoneyPit/";
      String     date = DateTimeFormat.dateOnly(DateTime.now());
      String filename = "${cell.title}_data_$date.csv";
      filename = filename.replaceAll(
        RegExp("[<>:\"/\\|?* \\n\\s]"),
        "",
      );

      File file = File(dir + filename);
      file.createSync(recursive: true);
      file.writeAsString(csv);

      onSuccess(file.path);
    } catch (e) {
      onFailed?.call(e);
    }
  }
}
