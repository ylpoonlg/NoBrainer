import 'package:flutter/material.dart';
import 'package:nobrainer/src/MoneyPage/Currencies.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/ShopPage/ShopItem.dart';
import 'package:nobrainer/src/ShopPage/ShopsList.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';

class ShopDetailsPage extends StatefulWidget {
  final ShopItem item;
  final Function onEdit;

  const ShopDetailsPage({
    required this.item,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  late ShopItem item;
  bool   pricePerItem = false;
  String currency     = "\$";

  List<Widget> _getShopsList() {
    List<Widget> result = [];
    for (String shop in item.shops) {
      result.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5,),
          child: Text(shop),
        )
      );
    }
    return result;
  }

  _loadCurrencySymbol() async {
    Settings settings = await settingsHandler.getSettings();
    setState(() {
      currency = Currencies.getCurrencySymbol(settings.currency);
    });
  }

  @override
  void initState() {
    super.initState();
    item = widget.item.clone();
    _loadCurrencySymbol();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    const EdgeInsetsGeometry listTilePadding = EdgeInsets.only(
      top:    16,
      left:   16,
      right:  16,
      bottom:  0,
    );

    return Scaffold(
      appBar: AppBar(
        title: item.id >= 0
          ? const Text("Edit Shopping Item")
          : const Text("New Shopping Item"),
        centerTitle: true,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Discard"),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (pricePerItem) {
                item.price = item.price;
                item.price *= item.quantity;
              }
              widget.onEdit(item);
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(80, 64)),
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
              controller: TextEditor.getController(item.title),
              onChanged: (text) {
                item.title = text;
              },
              decoration: const InputDecoration(
                labelText: "Item",
                hintText: "e.g. Fruits, Vegetables",
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
                      item.quantity.toString(),
                    ),
                    onChanged: (text) {
                      item.quantity = int.tryParse(text) ?? 1;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: "x ",
                      labelText: "Quantity",
                      hintText: "e.g. 1, 2, 3",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                // Price
                SizedBox(
                  width: screenWidth / 3,
                  child: TextField(
                    controller: TextEditor.getController(item.price.toString()),
                    onChanged: (text) {
                      item.price = double.tryParse(text) ?? 0;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: "$currency ",
                      labelText: "Price",
                      hintText: "How much?",
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
                          selected: List<String>.from(item.shops),
                          onChanged: (value) {
                            setState(() {
                              item.shops = value;
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
              controller: TextEditor.getController(item.desc),
              onChanged: (text) {
                item.desc = text;
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
