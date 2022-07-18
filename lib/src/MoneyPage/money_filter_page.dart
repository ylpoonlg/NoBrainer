import 'package:flutter/material.dart';
import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';
import 'package:nobrainer/src/MoneyPage/pay_methods.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';

class MoneyFilterPage extends StatefulWidget {
  final MoneyFilter           filter;
  final Function(MoneyFilter) onApply;
  const MoneyFilterPage({
    required this.filter,
    required this.onApply,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MoneyFilterPageState();
}

class _MoneyFilterPageState extends State<MoneyFilterPage> {
  MoneyFilter  filter = MoneyFilter();
  List<String> payMethods = [];

  _MoneyFilterPageState() {
    loadPayMethods();
  }

  loadPayMethods() async {
    payMethods = await PayMethods.getPayMethods();
    setState(() {});
  }

  _onApply() {
    widget.onApply(filter);
    //Navigator.of(context).pop();
  }

  _formatCategoryList() {
    const int maxLength = 30;
    List<String> list = filter.categories;
    if (list.isEmpty) return "All";
    List<String> catList = [];
    for (String catName in list) {
      catList.add(catName);
    }
    String result = catList.join(", ");
    return result.length > maxLength
      ? result.substring(0, maxLength) + "..."
      : result;
  }

  _formatPayMethodList() {
    const int maxLength = 30;
    List<String> list = filter.payMethods;
    if (list.isEmpty) return "All";
    String result = list.join(", ");
    return result.length > maxLength
      ? result.substring(0, maxLength) + "..."
      : result;
  }

  Widget buildCategoriesTile() {
    return ListTile(
      title: const Text("Categories"),
      trailing: TextButton(
        onPressed: () async {
          List<MoneyCategory> categories =
            await MoneyCategory.getCategories();
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
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            filter.categories = [];
                            Navigator.of(context).pop();
                          });
                        },
                        child: const Text("Clear"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ...categories.map(
                  (cat) => FinanceFilterList(
                    item: cat.name,
                    value: filter.categories.contains(cat.name),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          filter.categories.add(cat.name);
                        } else {
                          filter.categories.remove(cat.name);
                        }
                      });
                    },
                  ),
                ).toList(),
              ],
            ),
          );
        },
        child: Text(_formatCategoryList()),
      ),
    );
  }
  
  Widget buildPayMethodTile() {
    return ListTile(
      title: const Text("Payment Method"),
      trailing: TextButton(
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
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            filter.payMethods = [];
                            Navigator.of(context).pop();
                          });
                        },
                        child: const Text("Clear"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ...payMethods.map(
                  (payMethod) => FinanceFilterList(
                    item: payMethod,
                    value: filter.payMethods.contains(payMethod),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          filter.payMethods.add(payMethod);
                        } else {
                          filter.payMethods.remove(payMethod);
                        }
                      });
                    },
                  ),
                ).toList(),
              ],
            ),
          );
        },
        child: Text(_formatPayMethodList()),
      ),
    );
  }

  Widget buildDateFromTile() {
    return ListTile(
      title: const Text("Date from"),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          filter.dateFrom == null
            ? const SizedBox()
            : IconButton(
                onPressed: filter.dateFrom == null
                  ? null
                  : () {
                      setState(() {
                        filter.dateFrom = null;
                      });
                    },
                icon: const Icon(Icons.clear),
              ),
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DatePickerDialog(
                  initialDate: filter.dateFrom ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(3000),
                  initialCalendarMode: DatePickerMode.day,
                ),
              ).then((date) {
                setState(() {
                  if (date != null) {
                    filter.dateFrom = DateTime(
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
            child: Text(
              filter.dateFrom != null
                ? DateTimeFormat.dateOnly(filter.dateFrom!)
                : "Choose Date",
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateToTile() {
    return ListTile(
      title: const Text("Date to"),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          filter.dateTo == null
            ? const SizedBox()
            : IconButton(
                onPressed: filter.dateTo == null
                  ? null
                  : () {
                      setState(() {
                        filter.dateTo = null;
                      });
                    },
                icon: const Icon(Icons.clear),
              ),
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DatePickerDialog(
                  initialDate: filter.dateTo ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(3000),
                  initialCalendarMode: DatePickerMode.day,
                ),
              ).then((date) {
                setState(() {
                  if (date != null) {
                    filter.dateTo = DateTime(
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
            child: Text(filter.dateTo != null
              ? DateTimeFormat.dateOnly(filter.dateTo!)
              : "Choose Date"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    filter = widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: ElevatedButton.icon(
            onPressed: _onApply,
            icon:  const Icon(Icons.check),
            label: const Text("Apply Filter"),
          ),
        ),
        const Divider(),
        buildCategoriesTile(),
        buildPayMethodTile(),
        buildDateFromTile(),
        buildDateToTile(),
      ],
    );
  }
}



class FinanceFilterList extends StatefulWidget {
  final String         item;
  final bool           value;
  final Function(bool) onChanged;
  const FinanceFilterList({
    required this.item,
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FinanceFilterListState();
}

class _FinanceFilterListState extends State<FinanceFilterList> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: value,
        onChanged: (newVal) {
          if (newVal == null) return;
          setState(() {
            value = newVal;
            widget.onChanged(newVal);
          });
        },
      ),
      title: Text(widget.item),
    );
  }
}
