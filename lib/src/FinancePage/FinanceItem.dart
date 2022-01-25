import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/FinancePage/FinanceItemDetails.dart';

// Default FinanceItem
Map defaultFinanceItem = {
  "id": "set finance item id",
  "time": "a datetime object",
  "amount": 0,
  "title": "New Item",
  "cat": "general",
  "color": AppTheme.colorToMap(AppTheme.color["gray"]),
  "desc": "",
};

class FinanceItem extends StatefulWidget {
  Map data;
  Function onDelete, onUpdate;

  FinanceItem({
    required Map this.data,
    required Function this.onDelete,
    required this.onUpdate,
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

  Map<String, IconData> categoryIcon = {
    "general": Icons.group_work,
  };

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
      leading: Container(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(
          categoryIcon[widget.data["cat"] ?? "general"],
          color: AppTheme.mapToColor(widget.data["color"]),
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
      trailing: IconButton(
        onPressed: () {
          _onDelete(context);
        },
        icon: const Icon(Icons.close),
      ),
    );
  }
}
