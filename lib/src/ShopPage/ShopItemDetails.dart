import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/ShopPage/Shops.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';

class ShopItemDetails extends StatefulWidget {
  Map data;
  Function onUpdate;
  String currency;

  ShopItemDetails({
    required this.data,
    required this.onUpdate,
    this.currency = "\$",
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ShopItemsDetailsState(new Map.from(data));
}

class _ShopItemsDetailsState extends State<ShopItemDetails> {
  final Map data;
  bool pricePerItem = false;

  _ShopItemsDetailsState(this.data);

  List<Widget> _getShopsList() {
    List<Widget> result = [];
    for (String shop in data["shops"]??[]) {
      result.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5,),
          child: Text(shop),
        )
      );
    }
    return result;
  }

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

          ListTile(
            contentPadding: listTilePadding,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity
                SizedBox(
                  width: screenWidth / 3,
                  child: TextField(
                    controller: TextEditor.getController(
                        data["quantity"] != null
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
                    controller: TextEditor.getController(
                      data["price"]?.toStringAsFixed(2) ?? "0.00"
                    ),
                    onChanged: (text) {
                      data["price"] = double.tryParse(text) ?? 0;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: widget.currency + " ",
                      labelText: "Price",
                      hintText: "How much is this?",
                      border: const OutlineInputBorder(),
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
            title: const Text("Shops"),
            trailing: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Shops"),
                      content: SizedBox(
                        width: screenWidth,
                        height: 320,
                        child: ShopsList(
                          selected: List<String>.from(data["shops"] ?? []),
                          onChanged: (value) {
                            setState(() {
                              data["shops"] = value;
                            });
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
              icon: const Icon(Icons.add),
            ),
            subtitle: Wrap(
              direction: Axis.horizontal,
              children: _getShopsList(),
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
