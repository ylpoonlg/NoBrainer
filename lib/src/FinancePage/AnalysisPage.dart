import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/FinancePage/CategoryList.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';
import 'package:sqflite/sqflite.dart';

class AnalysisPage extends StatefulWidget {
  List<dynamic> financeList = [];
  AnalysisPage({required this.financeList});
  @override
  createState() => _AnalysisPageState(financeList);
}

class _AnalysisPageState extends State<AnalysisPage> {
  final List<dynamic> financeList; // Current status of the shopping list
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();
  String timeScope = financeAnalyzeScope[0]["value"];
  String currency = "\$";

  _AnalysisPageState(this.financeList) {
    getCurrencySymbol();
    DateTime now = DateTime.now();
    dateEnd = DateTime(now.year, now.month, now.day);
    dateStart = _getDateStart(dateEnd, timeScope);
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
        currency = currencySymbol[dbMap[0]["value"]] ?? "\$";
      });
    }
  }

  DateTime _getDateStart(DateTime dateEnd, String scope) {
    int newYear = dateEnd.year;
    int newMonth = dateEnd.month;
    int newDay = dateEnd.day;

    switch (scope) {
      case "week":
        return dateEnd.subtract(const Duration(days: 7));
      case "month":
        if (newMonth > 1) {
          newMonth--;
        } else {
          newMonth = 12;
          newYear--;
        }
        break;
      case "year":
        newYear--;
        if (newMonth == 2 && newDay == 29) newDay = 28;
        break;
    }

    return DateTime(newYear, newMonth, newDay);
  }

  void _onSelectDate(BuildContext context, {bool isDateEnd=true}) {
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
      });
    });
  }

  List<Widget> _getCategoryTiles() {
    /// Calculate the sutotal for each category and return a list of ListTiles
    List<Widget> result = [];
    List<Map> categories = CategoryListState.categories;
    Map<String, double> catSpending = {};
    for (var item in financeList) {
        String cat = item["cat"];
        DateTime date = DateTime.parse(item["time"]);
        date = DateTime(date.year, date.month, date.day);
        if (date.compareTo(dateStart) >= 0 && date.compareTo(dateEnd) <= 0) {
          if (item["spending"]) {
            catSpending[cat] = catSpending[cat]??0.0 - item["amount"];
          } else {
            catSpending[cat] = catSpending[cat]??0.0 + item["amount"];
          }
        }
    }
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
            padding: const EdgeInsets.all(10),
            child: Icon(
              cat["icon"],
              color: cat["color"],
            ),
          ),
          title: Text(cat["cat"]),
          trailing: Text(
            sign + currency + amount.abs().toString(),
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
    Color fgColor = Theme.of(context).textTheme.titleSmall?.color ?? Color(0);
    Color crdColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Analytics"),
        actions: [],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 30,
              top: 15,
              bottom: 10,
            ),
            child: const Text("Categories", style: TextStyle(fontSize: 20)),
          ),
          Container(
            height: screenHeight * 0.35,
            margin: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 5,
            ),
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
          const SizedBox(height: bottomSheetHeight),
        ],
      ),
      bottomSheet: Container(
        width: screenWidth,
        height: bottomSheetHeight,
        color: crdColor,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Text("Scope", style: Theme.of(context).textTheme.headline6),
            ),
            const SizedBox(height: 10),
            PopupMenuButton(
              initialValue: timeScope,
              onSelected: (val) {
                setState(() {
                    timeScope = val.toString();
                    dateStart = _getDateStart(dateEnd, timeScope);
                });
              },
              itemBuilder: (context) {
                  return financeAnalyzeScope.map((item) =>
                    PopupMenuItem(value: item["value"], child: Text(item["label"]))
                  ).toList();
              },
              child: Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: fgColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Center(
                  child: Text(timeScope == "" ? "- - -" :
                    financeAnalyzeScope.firstWhere((item) => item["value"] == timeScope)["label"]
                  ),
                ),
              ),
            ),
            SizedBox(
              width: screenWidth,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.skip_previous),
                  ),
                  TextButton(
                    onPressed: () {_onSelectDate(context, isDateEnd: false);},
                    child: Text(
                      DateTimeFormat.dateOnly(dateStart),
                    ),
                  ),
                  const Text("From - To"),
                  TextButton(
                    onPressed: () {_onSelectDate(context, isDateEnd: true);},
                    child: Text(
                      DateTimeFormat.dateOnly(dateEnd),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
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
