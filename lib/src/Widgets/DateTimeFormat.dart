class DateTimeFormat {
  static String dateFormat(DateTime date) {
    String YYYY = date.year.toString();
    String MM = date.month.toString();
    String DD = date.day.toString();

    String hh = date.hour.toString();
    String mm = date.minute.toString();

    if (MM.length < 2) MM = "0" + MM;
    if (DD.length < 2) DD = "0" + DD;
    if (hh.length < 2) hh = "0" + hh;
    if (mm.length < 2) mm = "0" + mm;
    return "$YYYY-$MM-$DD $hh:$mm";
  }

  static String dateOnly(DateTime date) {
    String datetime = dateFormat(date);
    return datetime.substring(0, 10);
  }
}
