import 'package:flutter/material.dart';
import 'package:nobrainer/src/MoneyPage/Currencies.dart';
import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';
import 'package:nobrainer/src/MoneyPage/pay_methods.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/MoneyPage/CategoryList.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';

class MoneyDetailsPage extends StatefulWidget {
  final MoneyItem           item;
  final Function(MoneyItem) onEdit;

  const MoneyDetailsPage({
    required this.item,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MoneyDetailsPageState();
}

class _MoneyDetailsPageState extends State<MoneyDetailsPage> {
  late MoneyItem item;
  String currency = "\$";

  _MoneyDetailsPageState() {
    loadCurrency();
  }

  loadCurrency() async {
    Settings settings = await settingsHandler.getSettings();
    setState(() {
      currency = Currencies.getCurrencySymbol(settings.currency);
    });
  }

  _onSelectCategory(MoneyCategory? category) {
    setState(() {
      item.category = category;
    });
    Navigator.of(context).pop();
  }

  void validateData() {
    if (item.title.isNotEmpty && item.amount >= 0) {
      widget.onEdit(item);
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid Input"),
          content: const Text(
            "Please check that the title must not be empty and amount must not be a negative number."
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            )
          ],
        ),
      );
    }
  }

  void _onSelectDeadline(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DatePickerDialog(
        initialDate: item.time,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialCalendarMode: DatePickerMode.day,
      ),
    ).then((date) {
      setState(() {
        // Pick Time
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(item.time),
        ).then((time) {
          setState(() {
            if (time != null) {
              item.time = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            }
          });
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    item = widget.item.clone();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    const EdgeInsetsGeometry listTilePadding = EdgeInsets.only(
      top: 16,
      left: 16,
      right: 16,
      bottom: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (item.id >= 0 ? "Edit " : "New ") +
          (item.isSpending ? "Spending" : "Income")
        ),
        centerTitle: true,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Discard"),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: validateData,
            child: const Text("Save"),
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(80, 64)),
            ),
          ),
        ],
      ),

      body: ListView(
        children: [
          // Title
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditor.getController(item.title),
              onChanged: (text) {
                item.title = text;
              },
              decoration: InputDecoration(
                labelText: item.isSpending ? "Spending" : "Income",
                hintText: item.isSpending
                  ? "e.g. Restaurant, Shopping"
                  : "e.g. Salary, Investments",
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // Amount
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditor.getController(
                item.amount.toStringAsFixed(2)
              ),
              onChanged: (text) {
                item.amount = double.tryParse(text) ?? 0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: currency + " ",
                labelText: "Amount",
                border: const OutlineInputBorder(),
              ),
            ),

            // Payment Method
            trailing: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Payment Method"),
                      content: SizedBox(
                        width: screenWidth,
                        height: 320,
                        child: PayMethodsList(
                          payMethod: item.payMethod,
                          onChanged: (value) {
                            item.payMethod = value;
                            Navigator.of(context).pop();
                          }
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        )
                      ],
                    );
                  }
                );
              },
              icon: const Icon(Icons.credit_card),
            ),
          ),

          // Category
          ListTile(
            contentPadding: listTilePadding,
            title: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.surface,
                ),
                foregroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      // Show Category Selector
                      return AlertDialog(
                        title: const Text("Category"),
                        content: SizedBox(
                          width: screenWidth,
                          height: 420,
                          child: CategoryList(
                            category: item.category,
                            onSelect: _onSelectCategory,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          )
                        ],
                      );
                    });
              },
              label: Text(
                item.category?.name ?? "Select A Category",
                style: TextStyle(color: item.category?.color),
              ),
              icon: Icon(
                item.category?.icon,
                color: item.category?.color,
              ),
            ),
          ),

          // Date
          ListTile(
            title: const Text("Date"),
            trailing: TextButton(
              onPressed: () {
                _onSelectDeadline(context);
              },
              child: Text(DateTimeFormat.dateFormat(item.time)),
            ),
          ),

          // Description box
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditor.getController(item.desc),
              onChanged: (text) {
                item.desc = text;
              },
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "Describe the item",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
