import 'dart:ffi';

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
  bool pricePerItem = false;

  _ShopItemsDetailsState(this.data);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    const EdgeInsetsGeometry listTilePadding = EdgeInsets.only(
      top: 16,
      left: 16,
      right: 16,
      bottom: 0,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Edit Shopping Item"),
        actions: [
          MaterialButton(
            onPressed: () {
              if (pricePerItem) {
                data["price"] = data["price"] ?? 0;
                data["price"] *=
                    double.tryParse(data["quantity"].toString()) ?? 1;
              }
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
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
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

          ListTile(
            contentPadding: listTilePadding,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity
                SizedBox(
                  width: screenWidth / 3,
                  child: TextField(
                    controller: TextEditingController(
                        text: data["quantity"] != null
                            ? data["quantity"].toString()
                            : "1"),
                    onChanged: (text) {
                      data["quantity"] = int.tryParse(text) ?? 1;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: "x ",
                      labelText: "Quantity",
                      hintText: "How many of this do you want?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // Price
                SizedBox(
                  width: screenWidth / 3,
                  child: TextField(
                    controller: TextEditingController(
                        text: data["price"] != null
                            ? data["price"].toString()
                            : "0"),
                    onChanged: (text) {
                      data["price"] = double.tryParse(text) ?? 0;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: "\$ ",
                      labelText: "Price",
                      hintText: "How much is this?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // Per Item
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("per item?"),
                    Checkbox(
                      value: pricePerItem,
                      onChanged: (value) {
                        setState(() {
                          pricePerItem = value ?? false;
                        });
                      },
                      activeColor: AppTheme.color["accent-primary"],
                      checkColor: AppTheme.color["white"],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Shop
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
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
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
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
