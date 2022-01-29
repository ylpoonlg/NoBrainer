import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/ShopPage/ShopItemDetails.dart';
import 'package:sqflite/sqflite.dart';

// Default ShopItem
Map defaultShopItem = {
  "id": "set shop item id",
  "quantity": "1",
  "shop": "",
  "price": 0,
  "status": false,
  "title": "New Item",
  "desc": "",
};

class ShopItem extends StatefulWidget {
  Map data;
  Function onDelete, onUpdate;

  ShopItem({
    required Map this.data,
    required Function this.onDelete,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShopItemState(data);
}

class _ShopItemState extends State<ShopItem> {
  bool status = false;
  String currency = "\$";

  _ShopItemState(data) {
    status = data["status"] ?? status;
    getCurrencySymbol();
  }

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

  /// Handles status selection.
  ///
  /// Calls back the updated data.
  void _onSelectStatus(value) {
    setState(() {
      status = value ?? false;
      widget.data["status"] = status;
      widget.onUpdate(widget.data);
    });
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      horizontalTitleGap: 4,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ShopItemDetails(
            onUpdate: widget.onUpdate,
            data: widget.data,
            currency: currency,
          ),
        ));
      },
      leading: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 0,
        children: [
          Checkbox(
            value: status,
            onChanged: _onSelectStatus,
            activeColor: AppTheme.color["accent-primary"],
            checkColor: AppTheme.color["white"],
          ),
          Container(
            width: 36,
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              widget.data["quantity"].toString() + " x",
              textAlign: TextAlign.end,
            ),
          ),
        ],
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
        widget.data["shop"].toString(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: IconButton(
        onPressed: () {
          _onDelete(context);
        },
        icon: const Icon(Icons.close),
      ),
    );
  }
}
