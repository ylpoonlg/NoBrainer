import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class ShopItemDetails extends StatefulWidget {
  Map data;
  Function onUpdate;

  ShopItemDetails({required this.data, required this.onUpdate, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ShopItemsDetailsState(new Map.from(data));
}

class _ShopItemsDetailsState extends State<ShopItemDetails> {
  final Map data;
  _ShopItemsDetailsState(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Edit Shopping Item"),
        actions: [
          MaterialButton(
            onPressed: () {
              widget.onUpdate(data);
              Navigator.of(context).pop();
            },
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
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: TextEditingController(text: data["title"]),
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
          // Quantity
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: TextEditingController(text: data["quantity"]),
              onChanged: (text) {
                data["quantity"] = text;
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                hintText: "How many of this do you want?",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Shop
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: TextEditingController(text: data["shop"]),
              onChanged: (text) {
                data["shop"] = text;
              },
              decoration: const InputDecoration(
                labelText: "Shop",
                hintText: "Where can you buy this from?",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Description box
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: TextEditingController(text: data["desc"]),
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

String dateFormat(DateTime date) {
  String YYYY = date.year.toString();
  String MM = date.month.toString();
  String DD = date.day.toString();

  String hh = date.hour.toString();
  String mm = date.minute.toString();

  if (MM.length < 2) MM = "0" + MM;
  if (DD.length < 2) DD = "0" + DD;
  if (hh.length < 2) hh = "0" + hh;
  if (mm.length < 2) mm = "0" + mm;
  return "$YYYY-$MM-$DD $hh:$mm";
}
