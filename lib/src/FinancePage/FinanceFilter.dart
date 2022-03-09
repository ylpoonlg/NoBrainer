import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/FinancePage/CategoryList.dart';
import 'package:nobrainer/src/FinancePage/PayMethods.dart';
import 'package:nobrainer/src/Widgets/BorderButton.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';

class FinanceFilter extends StatefulWidget {
  Map filter;
  Function(Map) onApply;
  FinanceFilter({
    Key? key,
    required this.filter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FinanceFilterState();
}

class _FinanceFilterState extends State<FinanceFilter> {
  Map? filter;

  _onApply() {
    Navigator.of(context).pop();
    widget.onApply(filter!);
  }

  _formatCategoryList() {
    const int MAX_LENGTH = 30;
    List list = filter!["cats"];
    if (list.isEmpty) return "All";
    List<String> catList = [];
    for (Map catMap in list) {
      catList.add(catMap["cat"].toString());
    }
    String result = catList.join(", ");
    return result.length > MAX_LENGTH
        ? result.substring(0, 30) + "..."
        : result;
  }

  _formatPayMethodList() {
    const int MAX_LENGTH = 30;
    List list = filter!["paymethod"];
    if (list.isEmpty) return "All";
    String result = list.join(", ");
    return result.length > MAX_LENGTH
        ? result.substring(0, 30) + "..."
        : result;
  }

  @override
  Widget build(BuildContext context) {
    // if filter is not set, retreive current state from widget
    filter ??= widget.filter;

    EdgeInsets selectorPadding = const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 16,
    );

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text(
              "Filter",
              style: Theme.of(context).textTheme.headline5,
            ),
            trailing: TextButton(
              onPressed: _onApply,
              child: const Text("Apply"),
            ),
          ),
          const Divider(),
          // Filter Categories
          ListTile(
            title: const Text("Categories"),
            trailing: BorderButton(
              padding: selectorPadding,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text("Categories"),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            BorderButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              onPressed: () {
                                setState(() {
                                  filter!["cats"] = [];
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text("Clear"),
                            ),
                            BorderButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Apply"),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      ...CategoryListState.categories
                          .map(
                            (cat) => FinanceFilterList(
                              item: cat["cat"],
                              value: filter!["cats"].contains(cat),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    filter!["cats"].add(cat);
                                  } else {
                                    filter!["cats"].remove(cat);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ],
                  ),
                );
              },
              child: Text(_formatCategoryList()),
            ),
          ),

          // Payment Method
          ListTile(
            title: const Text("Payment Method"),
            trailing: BorderButton(
              padding: selectorPadding,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text("Payment Method"),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            BorderButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              onPressed: () {
                                setState(() {
                                  filter!["paymethod"] = [];
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text("Clear"),
                            ),
                            BorderButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Apply"),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      ...PayMethods.payMethods
                          .map(
                            (payMethod) => FinanceFilterList(
                              item: payMethod,
                              value: filter!["paymethod"].contains(payMethod),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    filter!["paymethod"].add(payMethod);
                                  } else {
                                    filter!["paymethod"].remove(payMethod);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ],
                  ),
                );
              },
              child: Text(_formatPayMethodList()),
            ),
          ),

          // Filter Date From
          ListTile(
            title: const Text("Date from"),
            trailing: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  onPressed: filter!["date-from"] == null
                      ? null
                      : () {
                          setState(() {
                            filter!["date-from"] = null;
                          });
                        },
                  icon: const Icon(Icons.clear),
                ),
                BorderButton(
                  padding: selectorPadding,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DatePickerDialog(
                        initialDate: filter!["date-from"] ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                        initialCalendarMode: DatePickerMode.day,
                      ),
                    ).then((date) {
                      setState(() {
                        if (date != null) {
                          filter!["date-from"] = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            0,
                            0,
                          );
                        }
                      });
                    });
                  },
                  child: Text(filter!["date-from"] != null
                      ? DateTimeFormat.dateOnly(filter!["date-from"])
                      : "**-**-****"),
                ),
              ],
            ),
          ),

          // Filter Date To
          ListTile(
            title: const Text("Date to"),
            trailing: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  onPressed: filter!["date-to"] == null
                      ? null
                      : () {
                          setState(() {
                            filter!["date-to"] = null;
                          });
                        },
                  icon: const Icon(Icons.clear),
                ),
                BorderButton(
                  padding: selectorPadding,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DatePickerDialog(
                        initialDate: filter!["date-to"] ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                        initialCalendarMode: DatePickerMode.day,
                      ),
                    ).then((date) {
                      setState(() {
                        if (date != null) {
                          filter!["date-to"] = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            0,
                            0,
                          );
                        }
                      });
                    });
                  },
                  child: Text(filter!["date-to"] != null
                      ? DateTimeFormat.dateOnly(filter!["date-to"])
                      : "**-**-****"),
                ),
              ],
            ),
          ),
        ], // Filters List
      ),
    );
  }
}

class FinanceFilterList extends StatefulWidget {
  String item;
  bool? value;
  Function(bool?) onChanged;
  FinanceFilterList({
    Key? key,
    required this.item,
    required this.value,
    required this.onChanged,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FinanceFilterListState();
}

class _FinanceFilterListState extends State<FinanceFilterList> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: widget.value,
        activeColor: AppTheme.color["accent-primary"],
        checkColor: AppTheme.color["white"],
        onChanged: (value) {
          setState(() {
            widget.value = value;
            widget.onChanged(value);
          });
        },
      ),
      title: Text(widget.item),
    );
  }
}
