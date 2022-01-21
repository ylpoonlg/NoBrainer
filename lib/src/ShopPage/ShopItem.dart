import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/ShopPage/ShopItemDetails.dart';

// Default ShopItem
Map defaultShopItem = {
  "id": "set shop item id",
  "quantity": "1",
  "shop": "",
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

  _ShopItemState(data) {
    status = data["status"] ?? status;
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ShopItemDetails(
                    onUpdate: widget.onUpdate,
                    data: widget.data,
                  )));
        },
        child: Row(
          children: [
            Checkbox(
              value: status,
              onChanged: _onSelectStatus,
              activeColor: AppTheme.color["accent-primary"],
              checkColor: AppTheme.color["white"],
            ),
            Container(
              width: 40,
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                widget.data["quantity"].toString() + " x",
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.data["title"].toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Container(height: 5),
                    Text(
                      widget.data["shop"].toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  _onDelete(context);
                },
                icon: const Icon(Icons.close)),
          ],
        ),
      ),
    );
  }
}
