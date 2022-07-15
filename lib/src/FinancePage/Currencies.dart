class Currencies {
  static const String dollar = "dollar";
  static const String pound  = "pound";
  static const String euro   = "euro";
  static const String yen    = "yen";
  static const String ruble  = "ruble";

  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case Currencies.pound:
        return "£";
      case Currencies.euro:
        return "€";
      case Currencies.yen:
        return "¥";
      case Currencies.ruble:
        return "₽";
      default:
        return "\$";
    }
  }
}
