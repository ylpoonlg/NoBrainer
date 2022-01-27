import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/FinancePage/FinanceItemDetails.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';

// Default FinanceItem
Map defaultFinanceItem = {
  "id": "set finance item id",
  "time": "a datetime object",
  "amount": 0.00,
  "title": "New Item",
  "cat": "",
  "color": AppTheme.colorToMap(AppTheme.color["gray"]),
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
  State<StatefulWidget> createState() => _FinanceItemState(data);
}

class _FinanceItemState extends State<FinanceItem> {
  _FinanceItemState(data) {}

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
          ),
        ));
      },
      leading: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 36,
            padding: const EdgeInsets.only(left: 10),
            child: Icon(
              widget.catData["icon"],
              color: widget.catData["color"],
            ),
          ),
          Container(
            width: 64,
            padding: const EdgeInsets.only(left: 6),
            child: Text("\$" + widget.data["amount"].toString()),
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
        DateTimeFormat.dateFormat(DateTime.parse(widget.data["time"])),
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
