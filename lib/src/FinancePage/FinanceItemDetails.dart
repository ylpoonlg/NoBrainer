import 'package:flutter/material.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/FinancePage/CategoryList.dart';
import 'package:nobrainer/src/FinancePage/PayMethods.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';

class FinanceItemDetails extends StatefulWidget {
  Map data;
  Function onUpdate;
  String currency;

  FinanceItemDetails({
    required this.data,
    required this.onUpdate,
    this.currency = "\$",
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _FinanceItemsDetailsState(new Map.from(data));
}

class _FinanceItemsDetailsState extends State<FinanceItemDetails> {
  /// A copy of the original data
  final Map data;
  Map? currentCategory = null;


  _FinanceItemsDetailsState(this.data) {
    _getCategories();
    _getPayMethods();
  }

  _getPayMethods() async {
    await PayMethods.getPayMethods();
    List<String> payMethods = PayMethods.payMethods;
    setState(() {});
  }


  _getCategories() async {
    await CategoryListState.getCategories();
    CategoryListState.categories.forEach((cat) {
      if (cat["cat"] == data["cat"]) {
        currentCategory = cat;
      }
    });
    setState(() {});
  }

  _onSelectPayMethod(String methodName) {
  }

  /// onSelect called from category list
  _onSelectCategory(Map? cat) {
    setState(() {
      currentCategory = cat;
      data["cat"] = cat == null ? "" : cat["cat"];
    });
    Navigator.of(context).pop();
  }

  void validateData() {
    if (data["title"].length > 0 && data["amount"] >= 0) {
      widget.onUpdate(data);
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid Input"),
          content: const Text(
              "Please check that the title must not be empty and amount must not be a negative number."),
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
        initialDate: DateTime.parse(data["time"]),
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialCalendarMode: DatePickerMode.day,
      ),
    ).then((date) {
      setState(() {
        // Pick Time
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(DateTime.parse(data["time"])),
        ).then((time) {
          setState(() {
            if (time != null) {
              data["time"] = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              ).toString();
            }
          });
        });
      });
    });
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
        backgroundColor: AppTheme.color["appbar-background"],
        title: Text(data["spending"] ?? true ? "Edit Spending" : "Edit Income"),
        actions: [
          MaterialButton(
            onPressed: validateData,
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
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
              controller: TextEditor.getController(data["title"]),
              onChanged: (text) {
                data["title"] = text;
              },
              decoration: const InputDecoration(
                labelText: "Title",
                hintText: "Enter the title of the item",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Amount
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditor.getController(data["amount"] != null
                  ? data["amount"].toStringAsFixed(2)
                  : "0"),
              onChanged: (text) {
                data["amount"] = double.tryParse(text) ?? 0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: widget.currency + " ",
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
                          payMethod: data["paymethod"] ?? "",
                          onChanged: (value) {
                            data["paymethod"] = value;
                          }
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Confirm"),
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
            title: TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      // Show Category Selector
                      return AlertDialog(
                        title: const Text("Category"),
                        content: SizedBox(
                          width: screenWidth,
                          height: screenHeight,
                          child: CategoryList(
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
              // Current Category Button
              child: Row(
                children: (currentCategory == null)
                    ? [const Text("Select a Category")]
                    : [
                        Icon(
                          currentCategory!["icon"],
                          color: currentCategory!["color"],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          currentCategory!["cat"],
                          style: TextStyle(color: currentCategory!["color"]),
                        ),
                      ],
              ),
            ),
          ),

          // Date
          ListTile(
            title: Text(
              "Date",
              style: TextStyle(color: AppTheme.color["white"]),
            ),
            trailing: TextButton(
              onPressed: () {
                _onSelectDeadline(context);
              },
              child: Text(
                DateTimeFormat.dateFormat(DateTime.parse(data["time"])),
                style: TextStyle(color: AppTheme.color["white"]),
              ),
            ),
          ),

          // Description box
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditor.getController(data["desc"]),
              onChanged: (text) {
                data["desc"] = text;
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
