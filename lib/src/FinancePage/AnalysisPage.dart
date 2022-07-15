import 'dart:io';

import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/FinancePage/CategoryList.dart';
import 'package:nobrainer/src/FinancePage/Currencies.dart';
import 'package:nobrainer/src/FinancePage/PayMethods.dart';
import 'package:nobrainer/src/Functions/Functions.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class AnalysisPage extends StatefulWidget {
  List<dynamic> financeList = [];
  AnalysisPage({required this.financeList});
  @override
  createState() => _AnalysisPageState(financeList);
}

class _AnalysisPageState extends State<AnalysisPage> {
  final List<dynamic> financeList; // Current status of the shopping list
  Map<String, double> catSpending = {};
  Map<String, double> methodSpending = {};
  String currency = "\$";
  double totalSpendings = 0;
  double totalIncome = 0;
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();
  String timeScope = financeAnalyzeScope[0]["value"];

  _AnalysisPageState(this.financeList) {
    getCurrencySymbol();
    DateTime now = DateTime.now();
    dateEnd = DateTime(now.year, now.month, now.day);
    dateStart = _getPreviousDate(dateEnd, timeScope);
    _analyzeFinanceList();
  }

  _onExportData() async {
    if (!await DbHelper.checkPermissions()) return;

    List<List<dynamic>> rows = [];

    rows.add([
      "title",
      "amount",
      "spending",
      "paymethod",
      "category",
      "time",
      "desc",
    ]);
    for (var item in financeList) {
      rows.add([
        item["title"],
        item["amount"],
        item["spending"],
        item["paymethod"],
        item["cat"],
        item["time"].toString(),
        item["desc"],
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Successfully exported data to " + file.path),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to export data: " + e.toString()),
      ));
    }
  }

  getCurrencySymbol() async {
    final Database db = await DbHelper.database;
    final dbMap = await db.query(
      "settings",
      where: "name = ?",
      whereArgs: ["currency"],
    );
    if (dbMap.isNotEmpty) {
      setState(() {
        currency = Currencies.getCurrencySymbol(dbMap[0]["value"].toString());
      });
    }
  }

  DateTime _getPreviousDate(DateTime dateEnd, String scope) {
    int newYear = dateEnd.year;
    int newMonth = dateEnd.month;
    int newDay = dateEnd.day;
    switch (scope) {
      case "week":
        return dateEnd.subtract(const Duration(days: 6));
      case "month":
        int daysOffset = daysInMonth(newMonth, newYear) - 1;
        return DateTime(newYear, newMonth, newDay - daysOffset);
      case "year":
        newYear--;
        if (newMonth == 2 && newDay == 29) newDay = 28;
        break;
    }
    return DateTime(newYear, newMonth, newDay).add(const Duration(days: 1));
  }

  DateTime _getNextDate(DateTime dateStart, String scope) {
    int newYear = dateStart.year;
    int newMonth = dateStart.month;
    int newDay = dateStart.day;
    switch (scope) {
      case "week":
        return dateStart.add(const Duration(days: 6));
      case "month":
        int daysOffset = daysInMonth(newMonth, newYear) - 1;
        return DateTime(newYear, newMonth, newDay + daysOffset);
      case "year":
        newYear++;
        break;
    }
    return DateTime(newYear, newMonth, newDay)
        .subtract(const Duration(days: 1));
  }

  void _onSelectDate(BuildContext context, {bool isDateEnd = true}) {
    /// Prompts user for start or end date selection
    showDialog(
      context: context,
      builder: (context) => DatePickerDialog(
        initialDate: isDateEnd ? dateEnd : dateStart,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialCalendarMode: DatePickerMode.day,
      ),
    ).then((date) {
      setState(() {
        if (date != null) {
          if (isDateEnd) {
            dateEnd = DateTime(
              date.year,
              date.month,
              date.day,
            );
          } else {
            dateStart = DateTime(
              date.year,
              date.month,
              date.day,
            );
          }
        }
        timeScope = "";
        _analyzeFinanceList();
      });
    });
  }

  /// Returns a map of spendings for each category in financeList
  void _analyzeFinanceList() {
    totalSpendings = 0;
    totalIncome = 0;
    catSpending = {};
    methodSpending = {};
    for (var item in financeList) {
      String cat = item["cat"] ?? "";
      String payMethod = item["paymethod"] ?? "";
      DateTime date = DateTime.parse(item["time"]);
      date = DateTime(date.year, date.month, date.day);
      if (date.compareTo(dateStart) >= 0 && date.compareTo(dateEnd) <= 0) {
        if (!catSpending.containsKey(cat)) catSpending[cat] = 0.0;
        if (!methodSpending.containsKey(payMethod))
          methodSpending[payMethod] = 0.0;

        if (item["spending"]) {
          catSpending[cat] = catSpending[cat]! - item["amount"];
          methodSpending[payMethod] =
              methodSpending[payMethod]! - item["amount"];
          totalSpendings += item["amount"];
        } else {
          catSpending[cat] = catSpending[cat]! + item["amount"];
          methodSpending[payMethod] =
              methodSpending[payMethod]! + item["amount"];
          totalIncome += item["amount"];
        }
      }
    }
  }

  void _onNextPeriod() {
    setState(() {
      dateStart = dateEnd.add(const Duration(days: 1));
      dateEnd = _getNextDate(dateStart, timeScope);
      _analyzeFinanceList();
    });
  }

  void _onPreviousPeriod() {
    setState(() {
      dateEnd = dateStart.subtract(const Duration(days: 1));
      dateStart = _getPreviousDate(dateEnd, timeScope);
      _analyzeFinanceList();
    });
  }

  /// Returns horizontal Wrap with net total, spending and income
  List<Widget> _getTotalWrap() {
    EdgeInsets paddings = const EdgeInsets.only(
      left: 30,
      right: 30,
      top: 5,
      bottom: 5,
    );
    return <Widget>[
      const SizedBox(height: 15),
      Container(
        padding: paddings,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("Total", style: Theme.of(context).textTheme.headline4),
            Text(
              (totalIncome <= totalSpendings ? "-" : "+") +
                  currency +
                  (totalIncome - totalSpendings).abs().toStringAsFixed(2),
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
      Container(
        padding: paddings,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("  Spendings", style: Theme.of(context).textTheme.headline6),
            Text(
              "-" + currency + totalSpendings.toStringAsFixed(2),
            ),
          ],
        ),
      ),
      Container(
        padding: paddings,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("  Income", style: Theme.of(context).textTheme.headline6),
            Text(
              "+" + currency + totalIncome.toStringAsFixed(2),
            ),
          ],
        ),
      ),
      const Divider(),
    ];
  }

  List<Widget> _getCategoryTiles() {
    /// Calculate the sutotal for each category and return a list of ListTiles
    List<Widget> result = [];
    List<Map> categories = CategoryListState.categories;
    for (var cat in categories) {
      double? amount = catSpending[cat["cat"]];
      if (amount == null) continue;

      Color color = AppTheme.color["green"];
      String sign = "+";
      if (amount <= 0) {
        color = AppTheme.color["red"];
        sign = "-";
      }

      result.add(ListTile(
        leading: Container(
          padding: const EdgeInsets.all(5),
          child: Icon(
            cat["icon"],
            color: cat["color"],
          ),
        ),
        title: Text(cat["cat"]),
        trailing: Text(
          sign + currency + amount.abs().toStringAsFixed(2),
          style: TextStyle(color: color),
        ),
      ));
    }
    return result;
  }

  List<Widget> _getPayMethodTiles() {
    List<Widget> result = [];
    for (String payMethod in PayMethods.payMethods) {
      double? amount = methodSpending[payMethod];
      if (amount == null) continue;

      Color color = AppTheme.color["green"];
      String sign = "+";
      if (amount <= 0) {
        color = AppTheme.color["red"];
        sign = "-";
      }
      result.add(ListTile(
        title: Text(payMethod),
        trailing: Text(
          sign + currency + amount.abs().toStringAsFixed(2),
          style: TextStyle(color: color),
        ),
      ));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    const double bottomSheetHeight = 200;

    ScrollController catListScrollController = ScrollController();
    ScrollController methodListScrollController = ScrollController();
    Color fgColor = Theme.of(context).textTheme.titleSmall?.color ?? Color(0);
    Color crdColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _onExportData,
          ),
        ],
      ),

      body: ListView(
        children: [
          ..._getTotalWrap(),

          // Categories
          Container(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 5,
              bottom: 10,
            ),
            child: const Text("Categories", style: TextStyle(fontSize: 20)),
          ),
          Container(
            height: 320,
            margin: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              border: Border.all(
                color: fgColor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Scrollbar(
              controller: catListScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: ListView(
                controller: catListScrollController,
                children: _getCategoryTiles(),
              ),
            ),
          ),

          // Payment Methods
          Container(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 15,
              bottom: 10,
            ),
            child:
                const Text("Payment Methods", style: TextStyle(fontSize: 20)),
          ),
          Container(
            height: 240,
            margin: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              border: Border.all(
                color: fgColor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Scrollbar(
              controller: methodListScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: ListView(
                controller: methodListScrollController,
                children: _getPayMethodTiles(),
              ),
            ),
          ),
          const SizedBox(height: bottomSheetHeight),
        ],
      ),

      // Scope Controller
      bottomSheet: Container(
        width: screenWidth,
        height: bottomSheetHeight,
        color: crdColor,
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: screenWidth - 40,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text("Time Period",
                      style: Theme.of(context).textTheme.headline6),
                  PopupMenuButton(
                    initialValue: timeScope,
                    onSelected: (val) {
                      setState(() {
                        timeScope = val.toString();
                        dateStart = _getPreviousDate(dateEnd, timeScope);
                        _analyzeFinanceList();
                      });
                    },
                    itemBuilder: (context) {
                      return financeAnalyzeScope
                          .map((item) => PopupMenuItem(
                              value: item["value"], child: Text(item["label"])))
                          .toList();
                    },
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: fgColor,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Center(
                        child: Text(timeScope == ""
                            ? "- - -"
                            : financeAnalyzeScope.firstWhere(
                                (item) => item["value"] == timeScope)["label"]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: screenWidth,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                    onPressed: _onPreviousPeriod,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  TextButton(
                    onPressed: () {
                      _onSelectDate(context, isDateEnd: false);
                    },
                    child: Text(
                      DateTimeFormat.dateOnly(dateStart),
                    ),
                  ),
                  const Text("From - To"),
                  TextButton(
                    onPressed: () {
                      _onSelectDate(context, isDateEnd: true);
                    },
                    child: Text(
                      DateTimeFormat.dateOnly(dateEnd),
                    ),
                  ),
                  IconButton(
                    onPressed: _onNextPeriod,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
