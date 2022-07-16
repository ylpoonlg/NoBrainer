import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';
import 'package:nobrainer/src/MoneyPage/MoneyItem.dart';
import 'package:nobrainer/src/MoneyPage/NewCategory.dart';

class CategoryList extends StatefulWidget {
  final Function(MoneyCategory?) onSelect;

  const CategoryList({Key? key, required this.onSelect}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<MoneyCategory> categories = [];
  bool isCategoriesLoaded = false;

  _CategoryListState() {
    loadCategories();
  }
  
  loadCategories() async {
    categories = await MoneyCategory.getCategories();
    setState(() {
      isCategoriesLoaded = true;
    });
  }

  _onNewCategory() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewCategory(
          onCreate: (newCat) async {
            MoneyCategory.newCategory(newCat);
            setState(() {
              loadCategories();
            });
          },
        ),
      ),
    );
  }

  _onDeleteCategory(MoneyCategory category) async {
    await MoneyCategory.deleteCategory(category);
    setState(() {
      loadCategories();
    });
  }

  bool isCategoryDeletable(MoneyCategory category) {
    return true;
  }

  List<Widget> buildItemList() {
    const listTilePadding = EdgeInsets.symmetric(horizontal: 0);

    List<Widget> listTiles = [];
    listTiles.add(
      ListTile(
        onTap: () {
          widget.onSelect(null);
        },
        title: const Text("None"),
      ),
    );

    for (MoneyCategory category in categories) {
      listTiles.add(ListTile(
        contentPadding: listTilePadding,
        onTap: () {
          widget.onSelect(category);
        },
        leading: Icon(
          category.icon,
          color: category.color,
        ),
        title: Text(category.name),
        trailing: isCategoryDeletable(category)
          ? IconButton(
              onPressed: () {
                _onDeleteCategory(category);
              },
              icon: const Icon(Icons.delete),
            )
          : const SizedBox(width: 0, height: 0),
      ));
    }

    listTiles.add(
      ListTile(
        contentPadding: listTilePadding,
        title: TextButton(
          onPressed: _onNewCategory,
          child: const Text("+ Add a custom category"),
        ),
      ),
    );

    return listTiles;
  }

  @override
  Widget build(BuildContext context) {
    return isCategoriesLoaded
      ? Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          child: ListView(children: buildItemList()),
        )
      : const Center(child: CircularProgressIndicator());
  }
}
