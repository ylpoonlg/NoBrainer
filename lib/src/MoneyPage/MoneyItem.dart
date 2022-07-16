class MoneyItem {
  late int      id;
  late int      cellid;
  late String   title;
  late String   desc;
  late double   amount;
  late String   payMethod;
  late String   category;
  late DateTime time;
  late bool     isSpending;

  MoneyItem({
    this.id = -1,
    this.cellid = -1,
    this.title = "",
    this.desc = "",
    this.amount = 0,
    this.payMethod = "",
    this.category = "",
    this.isSpending = true,
    DateTime? time
  }) {
    this.time = time ?? DateTime.now();
  }
}

class MoneyFitler {
  List<String> category  = [];
  List<String> dateFrom  = [];
  List<String> dateTo    = [];
  List<String> payMethod = [];
}
