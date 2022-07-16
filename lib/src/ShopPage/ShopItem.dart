import 'dart:convert';

class ShopItem {
  late int          id;
  late int          cellid;
  late String       title;
  late String       desc;
  late int          status;
  late double       price;
  late int          quantity;
  late List<String> shops;

  ShopItem({
    this.id       = -1,
    this.cellid   = -1,
    this.title    = "",
    this.desc     = "",
    this.status   = 0,
    this.price    = 0,
    this.quantity = 1,
    this.shops    = const [],
  });

  static ShopItem from(Map row) {
    List<dynamic> shops = json.decode(row["shops"]);
    return ShopItem(
      id:       row["id"],
      cellid:   row["cellid"],
      title:    row["title"],
      desc:     row["desc"],
      status:   row["status"],
      price:    row["price"],
      quantity: row["quantity"],
      shops:    shops.map((e) => e.toString()).toList(),
    );
  }

  ShopItem clone() {
    return ShopItem(
      id:       id,
      cellid:   cellid,
      title:    title,
      desc:     desc,
      status:   status,
      price:    price,
      quantity: quantity,
      shops:    shops,
    );
  }

  Map<String, Object?> toMap({List<String> exclude = const []}) {
    Map<String, Object?> map = {
      "id":       id,
      "cellid":   cellid,
      "title":    title,
      "desc":     desc,
      "status":   status,
      "price":    price,
      "quantity": quantity,
      "shops":    json.encode(shops),
    };
    exclude.forEach((key) {
      map.remove(key);
    });
    return map;
  }
}

class ShopListFilter {
  static const String sortStatus = "status";
  static const String sortItem   = "item";

  String       sortMode = ShopListFilter.sortStatus;
  List<String> shops    = [];

  static String getFilterLabel(String value) {
    switch (value) {
      case ShopListFilter.sortStatus:
        return "Status";
      case ShopListFilter.sortItem:
        return "Title";
      default:
        return "Error";
    }
  }
}
