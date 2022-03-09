import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/ShopPage/Shops.dart';
import 'package:nobrainer/src/Widgets/BorderButton.dart';

class ShopFilter extends StatefulWidget {
  Map filter;
  Function(Map) onApply;
  ShopFilter({
    Key? key,
    required this.filter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShopFilterState();
}

class _ShopFilterState extends State<ShopFilter> {
  Map? filter;

  _onApply() {
    Navigator.of(context).pop();
    widget.onApply(filter!);
  }

  _formatList(List list) {
    const int MAX_LENGTH = 30;
    if (list.isEmpty) return "All";
    String result = list.join(", ");
    return result.length > MAX_LENGTH
        ? result.substring(0, 30) + "..."
        : result;
  }

  @override
  Widget build(BuildContext context) {
    // if filter is not set, retreive current state from widget
    filter ??= widget.filter;

    EdgeInsets selectorPadding = const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 16,
    );

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text(
              "Filter",
              style: Theme.of(context).textTheme.headline5,
            ),
            trailing: TextButton(
              onPressed: _onApply,
              child: const Text("Apply"),
            ),
          ),
          const Divider(),
          // Filter Shops
          ListTile(
            title: const Text("Shops"),
            trailing: BorderButton(
              padding: selectorPadding,
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
                            BorderButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              onPressed: () {
                                setState(() {
                                  filter!["shops"] = [];
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text("Clear"),
                            ),
                            BorderButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Apply"),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      ...Shops.shops
                          .map(
                            (shop) => ShopFilterList(
                              shop: shop,
                              value: filter!["shops"].contains(shop),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    filter!["shops"].add(shop);
                                  } else {
                                    filter!["shops"].remove(shop);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ],
                  ),
                );
              },
              child: Text(_formatList(filter!["shops"])),
            ),
          ),
          const Divider(),
          // Sort by
          ListTile(
            title: const Text("Sort by"),
            trailing: BorderButton(
              padding: selectorPadding,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text("Sort by"),
                    children: shopSortModes.map((mode) {
                      return ListTile(
                        title: Text(mode["label"]),
                        onTap: () {
                          setState(() {
                            filter!["sort-mode"] = mode["value"];
                            Navigator.of(context).pop();
                          });
                        },
                      );
                    }).toList(),
                  ),
                );
              },
              child: Text(
                shopSortModes.firstWhere(
                  (item) => item["value"] == filter!["sort-mode"],
                )["label"],
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
        activeColor: AppTheme.color["accent-primary"],
        checkColor: AppTheme.color["white"],
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
