import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:nobrainer/src/BrainCell/CellPage.dart';
import 'package:nobrainer/src/MoneyPage/Currencies.dart';
import 'package:nobrainer/src/SettingsHandler.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/ShopPage/ShopFilterPage.dart';
import 'package:nobrainer/src/ShopPage/ShopItem.dart';
import 'package:nobrainer/src/ShopPage/ShopDetailsPage.dart';
import 'package:sqflite/sqflite.dart';

class ShopPage extends StatefulWidget {
  final BrainCell cell;

  const ShopPage({required this.cell, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> implements CellPage<ShopItem> {
  @override
  List<ShopItem> cellItems = [];

  @override
  bool isItemsLoaded = false;

  ShopListFilter filter   = ShopListFilter();
  String         currency = "\$";

  _ShopPageState() {
    loadItems();
    loadCurrency();
  }

  loadCurrency() async {
    Settings settings = await settingsHandler.getSettings();
    setState(() {
      currency = Currencies.getCurrencySymbol(settings.currency);
    });
  }

  @override
  loadItems() async {
    Database db = await DbHelper.database;
    List<Map> rows = await db.query(
      DbTableName.shopItems,
      where: "cellid = ?",
      whereArgs: [widget.cell.cellid],
    );

    cellItems = [];
    for (Map row in rows) {
      cellItems.add(ShopItem.from(row));
    }

    setState(() {
      isItemsLoaded = true;
    });
  }

  @override
  newItem(ShopItem item) async {
    Database db = await DbHelper.database;
    await db.insert(
      DbTableName.shopItems,
      item.toMap(exclude: ["id"]),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    loadItems();
  }

  @override
  editItem(ShopItem item) async {
    if (item.id < 0) {
      newItem(item);
      return;
    }

    Database db = await DbHelper.database;
    await db.update(
      DbTableName.shopItems,
      item.toMap(exclude: ["id", "cellid"]),
      where: "id = ?",
      whereArgs: [item.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    loadItems();
  }

  @override
  deleteItem(ShopItem item) async {
    setState(() {
      isItemsLoaded = false;
    });

    Database db = await DbHelper.database;
    await db.delete(
      DbTableName.shopItems,
      where: "id = ?",
      whereArgs: [item.id],
    );

    loadItems();
  }

  _clearBoughtItems() async {
    setState(() {
      isItemsLoaded = false;
    });

    Database db = await DbHelper.database;
    await db.delete(
      DbTableName.shopItems,
      where: "cellid = ? AND status > ?",
      whereArgs: [widget.cell.cellid, 0],
    );

    loadItems();
  }

  bool _isFilterSet() {
    return filter.shops.isNotEmpty;
  }


  @override
  Widget buildItemTile(ShopItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      horizontalTitleGap: 4,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ShopDetailsPage(
            item: item,
            onEdit: editItem,
          ),
        ));
      },
      leading: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 0,
        children: [
          Checkbox(
            value: item.status > 0,
            onChanged: (value) {
              value ??= false;
              item.status = value ? 1 : 0;
              editItem(item);
            },
          ),
          Container(
            width: 36,
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              item.quantity.toString() + " x",
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(
        item.shops.join(", "),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "$currency ${item.price.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    key:     Key("delete-alert-${item.id}"),
                    title:   const Text("Delete Confirmation"),
                    content: Text("Do you want to delete \"${item.title}\"?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteItem(item);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Confirm"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  List<ShopItem> filterItems() {
    List<ShopItem> filteredItems = [];

    bool shopInFilter(List shops) {
      if (filter.shops.isEmpty) return true;
      for (String shop in shops) {
        for (String filteredShop in filter.shops) {
          if (shop == filteredShop) return true;
        }
      }
      return false;
    }

    for (ShopItem item in cellItems) {
      if (shopInFilter(item.shops)) filteredItems.add(item);
    }

    filteredItems.sort((i, j) {
      if (filter.sortMode == ShopListFilter.sortItem) {
        return i.title.compareTo(j.title);
      }
      return i.status.compareTo(j.status);
    });

    return filteredItems;
  }

  @override
  List<Widget> buildItemList() {
    List<Widget> items = [];
    for (ShopItem item in filterItems()) {
      items.add(buildItemTile(item));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cell.title),
        actions: [
          IconButton(
            // Clear Button
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  key:     const Key("clear-bought-items"),
                  title:   const Text("Delete Confirmation"),
                  content: const Text(
                    "Are you sure you want to remove all the checked items?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          _clearBoughtItems();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Confirm")),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.remove_done),
            tooltip: "Clear checked items",
          ),
          IconButton(
            // Filter Button
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ShopFilterPage(
                    filter: filter,
                    onApply: (newFilter) {
                      setState(() {
                        filter = newFilter;
                      });
                    },
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.filter_list,
              color: _isFilterSet()
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: "Filter and Sort",
          ),
        ],
      ),
      body: isItemsLoaded ?
        ListView(
          key:      const Key("shoplistview"),
          children: <Widget>[
            _isFilterSet()
              ? MaterialButton(
                child: const Text("Clear Filter"),
                onPressed: () {
                  setState(() {
                    filter = ShopListFilter();
                  });
                },
              ) : const SizedBox()
            ] + buildItemList(),
        ) : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ShopDetailsPage(
              item: ShopItem(
                cellid: widget.cell.cellid,
              ),
              onEdit: editItem,
            )
          ));
        },
      ),
    );
  }
}
