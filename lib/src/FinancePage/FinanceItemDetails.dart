import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class FinanceItemDetails extends StatefulWidget {
  Map data;
  Function onUpdate;

  FinanceItemDetails({required this.data, required this.onUpdate, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _FinanceItemsDetailsState(new Map.from(data));
}

class _FinanceItemsDetailsState extends State<FinanceItemDetails> {
  final Map data;

  _FinanceItemsDetailsState(this.data);

  List getCategories() {
    return [
      {
        "cat": "",
        "color": AppTheme.color["gray"],
      }
    ];
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
        title: const Text("Edit Finance"),
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

          // Amount
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditingController(
                  text:
                      data["amount"] != null ? data["amount"].toString() : "0"),
              onChanged: (text) {
                data["amount"] = double.tryParse(text) ?? 0;
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: "\$ ",
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
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
                      return AlertDialog(
                        title: const Text("Category"),
                        content: SizedBox(
                          width: screenWidth,
                          height: screenHeight,
                          child: ListView(
                            children: [
                              ListTile(
                                onTap: () {},
                                title: const Text("General"),
                              ),
                            ],
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
              child: Row(
                children: [
                  Icon(
                    Icons.group_work,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text("General"),
                ],
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
