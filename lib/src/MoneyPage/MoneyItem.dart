import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';

class MoneyItem {
  late int            id;
  late int            cellid;
  late String         title;
  late String         desc;
  late double         amount;
  late String         payMethod;
  late MoneyCategory? category;
  late DateTime       time;
  late bool           isSpending;

  MoneyItem({
    this.id = -1,
    this.cellid = -1,
    this.title = "",
    this.desc = "",
    this.amount = 0,
    this.payMethod = "",
    this.category,
    this.isSpending = true,
    DateTime? time
  }) {
    this.time = time ?? DateTime.now();
  }

  static MoneyItem from(Map row, MoneyCategory? category) {
    return MoneyItem(
      id:         row["id"],
      cellid:     row["cellid"],
      title:      row["title"],
      desc:       row["desc"],
      amount:     row["amount"],
      payMethod:  row["paymethod"],
      category:   category,
      time:       DateTime.parse(row["time"]),
      isSpending: row["isspending"] == 1,
    );
  }

  MoneyItem clone() {
    return MoneyItem(
      id:         id,
      cellid:     cellid,
      title:      title,
      desc:       desc,
      amount:     amount,
      payMethod:  payMethod,
      category:   category,
      isSpending: isSpending,
      time:       time,
    );
  }
  
  Map<String, Object?> toMap({List<String> exclude = const []}) {
    Map<String, Object?> map = {
      "id":         id,
      "cellid":     cellid,
      "title":      title,
      "desc":       desc,
      "amount":     amount,
      "paymethod":  payMethod,
      "category":   category?.name,
      "time":       time.toString(),
      "isspending": isSpending ? 1 : 0,
    };
    exclude.forEach((key) {
      map.remove(key);
    });
    return map;
  }
}


class MoneyFilter {
  List<String> categories = [];
  DateTime?    dateFrom;
  DateTime?    dateTo;
  List<String> payMethods = [];
}


