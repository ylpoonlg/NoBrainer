import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nobrainer/src/MoneyPage/AnalysisPage/data_exporter.dart';
import 'package:nobrainer/src/MoneyPage/AnalysisPage/time_scope_controller.dart';
import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';
import 'package:nobrainer/src/MoneyPage/Currencies.dart';
import 'package:nobrainer/src/MoneyPage/pay_methods.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class AnalysisPage extends StatefulWidget {
  final List<MoneyItem> cellItems;

  const AnalysisPage({
    required this.cellItems,
    Key? key,
  }) : super(key: key);

  @override
  createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late List<MoneyItem>  cellItems;

  List<MoneyCategory> categories = [];
  List<String>        payMethods = [];
  String currency                = "\$";

  double totalSpendings = 0;
  double totalIncome    = 0;
  Map<String, double> catSpending    = {};
  Map<String, double> methodSpending = {};
  DateTime dateStart    = DateTime.now();
  DateTime dateEnd      = DateTime.now();
  String   timeScope    = TimeScope.unset;

  ScrollController catListScrollController    = ScrollController();
  ScrollController methodListScrollController = ScrollController();

  _AnalysisPageState() {
    getResources();
    DateTime now = DateTime.now();
    dateEnd      = DateTime(now.year, now.month, now.day);
    //dateStart    = _getPreviousDate(dateEnd, timeScope);
    dateStart    = dateEnd.subtract(const Duration(days: 7));
  }

  _onExportData() async {
    await DataExporter().exportData(
      cellItems: cellItems,
      onSuccess: (path) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Successfully exported data to " + path),
        ));
      },
      onFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to export data: " + e.toString()),
        ));
      }
    );
  }

  /// Get currency symbol and money categories
  getResources() async {
    Settings settings = await settingsHandler.getSettings();
    currency = Currencies.getCurrencySymbol(settings.currency);
    categories = await MoneyCategory.getCategories();
    payMethods = await PayMethods.getPayMethods();
    setState(() {});
  }

  /*
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
  */

  /// Returns a map of spendings for each category in financeList
  void _analyzeFinanceList() {
    totalSpendings = 0;
    totalIncome = 0;
    catSpending = {};
    methodSpending = {};
    for (MoneyItem item in cellItems) {
      String catName = item.category?.name ?? "";

      // Only get date and ignore time
      DateTime date = item.time;
      date = DateTime(date.year, date.month, date.day);

      if (date.compareTo(dateStart) >= 0 && date.compareTo(dateEnd) <= 0) {
        if (item.isSpending) {
          catSpending[catName] = catSpending[catName]??0 - item.amount;
          methodSpending[item.payMethod] =
              methodSpending[item.payMethod]??0 - item.amount;
          totalSpendings += item.amount;
        } else {
          catSpending[catName] = catSpending[catName]??0 + item.amount;
          methodSpending[item.payMethod] =
              methodSpending[item.payMethod]??0 + item.amount;
          totalIncome += item.amount;
        }
      }
    }
  }

  List<Widget> buildTotalItems() {
    return [
      Text(
        "Overview",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      ListTile(
        title: Text(
          "Total",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        trailing: Text(
          (totalIncome <= totalSpendings ? "-" : "+")
            + currency
            + (totalIncome - totalSpendings).abs().toStringAsFixed(2),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),

      ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: 0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        title: Text(
          "Spendings",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Text(
          "-" + currency + totalSpendings.toStringAsFixed(2),
        ),
      ),

      ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: 0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        title: Text(
          "Income",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Text(
          "+" + currency + totalIncome.toStringAsFixed(2),
        ),
      ),

      const Divider(),

      const ListTile(title: Text("Test")),
      const ListTile(title: Text("Test")),
      const ListTile(title: Text("Test")),
      const ListTile(title: Text("Test")),
      const ListTile(title: Text("Test")),
      const ListTile(title: Text("Test")),
      const ListTile(title: Text("Test")),
      const ListTile(title: Text("Test")),
    ];
  }

  List<Widget> buildCategoriesList() {
    /// Calculate the sutotal for each category and return a list of ListTiles
    List<Widget> result = [];
    for (MoneyCategory cat in categories) {
      double? amount = catSpending[cat.name];
      if (amount == null) continue;

      result.add(ListTile(
        leading: Container(
          padding: const EdgeInsets.all(5),
          child: Icon(
            cat.icon,
            color: cat.color,
          ),
        ),
        title: Text(cat.name),
        trailing: Text(
          (amount <= 0 ? "-" : "+") +
            currency + amount.abs().toStringAsFixed(2),
          style: TextStyle(
            color: amount <= 0 ? Palette.negative : Palette.positive
          ),
        ),
      ));
    }
    return result;
  }

  List<Widget> buildPayMethodsList() {
    List<Widget> result = [];
    for (String payMethod in payMethods) {
      double? amount = methodSpending[payMethod];
      if (amount == null) continue;

      result.add(ListTile(
        title: Text(payMethod),
        trailing: Text(
          (amount <= 0 ? "-" : "+") +
            currency + amount.abs().toStringAsFixed(2),
          style: TextStyle(
            color: amount <= 0 ? Palette.negative : Palette.positive
          ),
        ),
      ));

    }

    return result;
  }

  List<Widget> buildAnalysisPages({required double height}) {
    return [
      Column(
        mainAxisAlignment:  MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...buildTotalItems(),
        ],
      ),

      Column(
        mainAxisAlignment:  MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Categories",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Container(
            height: max(140, height - 140),
            margin: const EdgeInsets.symmetric(
              vertical: 20,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color:        Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: VsScrollbar(
              controller: catListScrollController,
              child: ListView(
                controller: catListScrollController,
                children: buildCategoriesList(),
              ),
            ),
          ),
        ],
      ),

      Column(
        mainAxisAlignment:  MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Payment Methods",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Container(
            height: max(140, height - 140),
            margin: const EdgeInsets.symmetric(
              vertical: 20,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color:        Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: VsScrollbar(
              controller: methodListScrollController,
              child: ListView(
                controller: methodListScrollController,
                children: buildPayMethodsList(),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    cellItems = widget.cellItems;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  @override
  Widget build(BuildContext context) {
    double bottomSheetHeight = MediaQuery.of(context).size.height < 500
      ? 0 : 200;
    double pageHeight        =
      MediaQuery.of(context).size.height - bottomSheetHeight - 160;
    double pageWidth         = MediaQuery.of(context).size.width - 80;


    _analyzeFinanceList();
    List<Widget> pages = buildAnalysisPages(height: pageHeight);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _onExportData,
          ),
        ],
      ),

      body: Center(
        child: Container(
          margin:  EdgeInsets.only(bottom: bottomSheetHeight),
          child:  ScrollSnapList(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {
              return Container(
                width:   pageWidth,
                padding: const EdgeInsets.symmetric(
                  vertical: 30, horizontal: 10,
                ),
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    height: pageHeight,
                    child: ListView(
                      children: [pages[i]]
                    ),
                  ),
                ),
              );
            },
            itemCount: pages.length,
            itemSize: pageWidth,
            onItemFocus: (i) {
            },
          ),
        ),
      ),

      bottomSheet: TimeScopeController(
        height: bottomSheetHeight,
      ),
    );
  }
}

