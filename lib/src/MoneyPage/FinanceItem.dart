import 'package:flutter/material.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/FinancePage/Currencies.dart';
import 'package:nobrainer/src/FinancePage/FinanceItemDetails.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';
import 'package:sqflite/sqflite.dart';

// Default FinanceItem
Map defaultFinanceItem = {
  "id": "set finance item id",
  "title": "New Item",
  "amount": 0.00,
  "spending": true,
  "paymethod": "",
  "cat": "",
  "color": AppTheme.colorToMap(Colors.grey),
  "time": "a datetime object",
  "desc": "",
};

class FinanceItem extends StatefulWidget {
  Map data, catData;
  Function onDelete, onUpdate;

  FinanceItem({
    required Map this.data,
    required Function this.onDelete,
    required this.onUpdate,
    required this.catData,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FinanceItemState();
}

class _FinanceItemState extends State<FinanceItem> {
  _FinanceItemState() {
    getCurrencySymbol();
  }

  @override
  void setState(f) {
    if (mounted) {
      super.setState(f);
    }
  }

  String currency = "\$";

  /// Show delete confirmation popup.
  ///
  /// If confirmed, call the callback function.
  void _onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: Key("delete-alert-" + widget.data["id"]),
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  widget.onDelete(widget.data["id"]);
                  Navigator.of(context).pop();
                },
                child: const Text("Confirm")),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      horizontalTitleGap: 4,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FinanceItemDetails(
            onUpdate: widget.onUpdate,
            data: widget.data,
            currency: currency,
          ),
        ));
      },
      leading: Container(
        margin: const EdgeInsets.only(left: 10),
        child: Icon(
          widget.catData["icon"],
          color: widget.catData["color"],
        ),
      ),
      title: Text(
        widget.data["title"].toString(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(
        DateTimeFormat.dateFormat(DateTime.parse(widget.data["time"])),
      ),
      trailing: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            child: Text(
              (widget.data["spending"] ?? true ? "-" : "+") +
                  currency +
                  widget.data["amount"].toStringAsFixed(2),
              style: TextStyle(
                color: widget.data["spending"] ?? true
                    ? AppTheme.color["red"]
                    : AppTheme.color["green"],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _onDelete(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
