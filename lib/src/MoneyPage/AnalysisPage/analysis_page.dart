import 'package:flutter/material.dart';
import 'package:nobrainer/src/MoneyPage/AnalysisPage/data_exporter.dart';
import 'package:nobrainer/src/MoneyPage/AnalysisPage/time_scope_controller.dart';
import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';
import 'package:nobrainer/src/MoneyPage/Currencies.dart';
import 'package:nobrainer/src/MoneyPage/pay_methods.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
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
  String timeScope      = TimeScope.unset;

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

  @override
  void initState() {
    super.initState();
    cellItems = widget.cellItems;
  }

  @override
  Widget build(BuildContext context) {
    const double bottomSheetHeight = 200;

    ScrollController catListScrollController    = ScrollController();
    ScrollController methodListScrollController = ScrollController();

    _analyzeFinanceList();

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

      body: ListView(
        children: [
          ...buildTotalItems(),

          // Categories
          Container(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 5,
              bottom: 10,
            ),
            child: Text(
              "Categories",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 5,
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

          // Payment Methods
          Container(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 15,
              bottom: 10,
            ),
            child: Text(
              "Payment Methods",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 5,
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
          const SizedBox(height: bottomSheetHeight + 50),
        ],
      ),

      bottomSheet: TimeScopeController(
        height: bottomSheetHeight,
      ),
    );
  }
}

