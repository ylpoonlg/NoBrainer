import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
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
  final BrainCell       cell;

  const AnalysisPage({
    required this.cell,
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

  TimeScope timeScope = TimeScope(scope: TimeScope.week);

  ScrollController catListScrollController    = ScrollController();
  ScrollController methodListScrollController = ScrollController();

  _AnalysisPageState() {
    getResources();
  }

  _onExportData() async {
    await DataExporter().exportData(
      cell:      widget.cell,
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

      if (date.compareTo(timeScope.dateFrom) >= 0
          && date.compareTo(timeScope.dateTo) <= 0) {
        if (item.isSpending) {
          catSpending[catName] = (catSpending[catName]??0) - item.amount;
          methodSpending[item.payMethod] =
            (methodSpending[item.payMethod]??0) - item.amount;
          totalSpendings += item.amount;
        } else {
          catSpending[catName] = (catSpending[catName]??0) + item.amount;
          methodSpending[item.payMethod] =
            (methodSpending[item.payMethod]??0) + item.amount;
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

      const SizedBox(height: 30),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            (totalIncome <= totalSpendings ? "-" : "+")
              + currency
              + (totalIncome - totalSpendings).abs().toStringAsFixed(2),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),

      const SizedBox(height: 5),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "    Spendings",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            "-" + currency + totalSpendings.toStringAsFixed(2),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "    Income",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            "+" + currency + totalIncome.toStringAsFixed(2),
          ),
        ],
      ),

      const Divider(),

      // Container(
      //   height: 160,
      //   color: Theme.of(context).colorScheme.background,
      //   child: const Center(
      //     child: Text("Graph/Comparison"),
      //   ),
      // ),
    ];
  }

  List<Widget> buildCategoriesList() {
    List<Widget> result = [];
    for (MoneyCategory cat in categories) {
      double? amount = catSpending[cat.name];
      if (amount == null) continue;

      result.add(ListTile(
        leading: Icon(
          cat.icon,
          color: cat.color,
          size: 20,
        ),
        minLeadingWidth: 10,
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
            height: max(140, height - 130),
            margin: const EdgeInsets.symmetric(
              vertical: 20,
            ),
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
            height: max(140, height - 130),
            margin: const EdgeInsets.symmetric(
              vertical: 20,
            ),
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
    double bottomSheetHeight =
      MediaQuery.of(context).size.height < 500 ? 0 : 200;
    double pageHeight        =
      MediaQuery.of(context).size.height - bottomSheetHeight - 160;
    double pageWidth         =
      MediaQuery.of(context).size.width - 80;


    _analyzeFinanceList();
    List<Widget> pages = buildAnalysisPages(height: pageHeight);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.share_outline),
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
        scope: timeScope,
        onChange: (scope) {
          setState(() {
            timeScope = scope;
          });
        },
        height: bottomSheetHeight,
      ),
    );
  }
}

