import 'package:flutter/widgets.dart';

abstract class CellPage <T> {
  List<T> cellItems     = [];
  bool    isItemsLoaded = false;
  loadItems();
  newItem(T item);
  editItem(T item);
  deleteItem(T item);

  Widget       buildItemTile(T item);
  List<Widget> buildItemList();
}
