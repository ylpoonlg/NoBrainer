import 'package:flutter/material.dart';
import 'package:nobrainer/src/ShopPage/ShopItem.dart';
import 'package:nobrainer/src/ShopPage/ShopsList.dart';

class ShopFilterPage extends StatefulWidget {
  final ShopListFilter           filter;
  final Function(ShopListFilter) onApply;
  const ShopFilterPage({
    Key? key,
    required this.filter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShopFilterPageState();
}

class _ShopFilterPageState extends State<ShopFilterPage> {
  late ShopListFilter filter;
  List<String>        shops = [];
  
  _ShopFilterPageState() {
    loadShops();
  }
  
  loadShops() async {
    shops = await Shops.getShops();
    setState(() {});
  }

  _onApply() {
    Navigator.of(context).pop();
    widget.onApply(filter);
  }

  _formatList(List list) {
    const int maxLength = 30;
    if (list.isEmpty) return "All";
    String result = list.join(", ");
    return result.length > maxLength
      ? result.substring(0, 30) + "..."
      : result;
  }

  EdgeInsets selectorPadding = const EdgeInsets.symmetric(
    vertical: 6,
    horizontal: 16,
  );

  Widget buildShopsTile() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return ListTile(
      title: const Text("Shops"),
      trailing: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              title: const Text("Shops"),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            filter.shops = [];
                            Navigator.of(context).pop();
                          });
                        },
                        child: const Text("Clear"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ...shops.map(
                  (shop) => ShopFilterList(
                    shop: shop,
                    value: filter.shops.contains(shop),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          filter.shops.add(shop);
                        } else {
                          filter.shops.remove(shop);
                        }
                      });
                    },
                  ),
                ).toList(),
              ],
            ),
          );
        },
        child: Text(_formatList(filter.shops)),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    filter = widget.filter;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: ElevatedButton.icon(
              onPressed: _onApply,
              icon:  const Icon(Icons.check),
              label: const Text("Apply Filter"),
            ),
          ),
          const Divider(),
          buildShopsTile(),

          // Sort by
          ListTile(
            title: const Text("Sort by"),
            trailing: OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text("Sort by"),
                    children: [
                      ShopListFilter.sortStatus,
                      ShopListFilter.sortItem,
                    ].map((String mode) {
                      return ListTile(
                        title: Text(
                          ShopListFilter.getFilterLabel(mode)
                        ),
                        onTap: () {
                          setState(() {
                            filter.sortMode = mode;
                            Navigator.of(context).pop();
                          });
                        },
                      );
                    }).toList(),
                  ),
                );
              },
              child: Text(
                ShopListFilter.getFilterLabel(filter.sortMode),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShopFilterList extends StatefulWidget {
  String shop;
  bool? value;
  Function(bool?) onChanged;
  ShopFilterList({
    Key? key,
    required this.shop,
    required this.value,
    required this.onChanged,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ShopFilterListState();
}

class _ShopFilterListState extends State<ShopFilterList> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: widget.value,
        onChanged: (value) {
          setState(() {
            widget.value = value;
            widget.onChanged(value);
          });
        },
      ),
      title: Text(widget.shop),
    );
  }
}
