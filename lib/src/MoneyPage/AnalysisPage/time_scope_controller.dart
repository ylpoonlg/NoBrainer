import 'package:flutter/material.dart';

class TimeScope {
  static const String week  = "week";
  static const String month = "month";
  static const String year  = "year";
  static const String unset = "unset";

  static String getLabel(String scope) {
    switch (scope) {
      case TimeScope.week:
        return "Week";
      case TimeScope.month:
        return "Month";
      case TimeScope.year:
        return "Year";
      default:
        return "Unset";
    }
  }

  late DateTime dateFrom;
  late DateTime dateTo;
  String scope = TimeScope.unset;

  TimeScope({DateTime? from, DateTime? to}) {
    dateFrom = from ?? DateTime.now();
    dateTo   = to   ?? DateTime.now();
  }

}


class TimeScopeController extends StatefulWidget {
  final double height;

  const TimeScopeController({
    required this.height,
    Key? key,
  }) : super(key: key);

  @override
    State<StatefulWidget> createState() => _TimeScopeControllerState();
}

class _TimeScopeControllerState extends State<TimeScopeController> {

  /*
  void _onNextPeriod() {
    setState(() {
      dateStart = dateEnd.add(const Duration(days: 1));
      dateEnd = _getNextDate(dateStart, timeScope);
      _analyzeFinanceList();
    });
  }

  void _onPreviousPeriod() {
    setState(() {
      dateEnd = dateStart.subtract(const Duration(days: 1));
      dateStart = _getPreviousDate(dateEnd, timeScope);
      _analyzeFinanceList();
    });
  }
  */
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth  = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width:  screenWidth,
      height: widget.height,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const Center(child: Text("TimeScopeController")),
    );
    /*
    return Container(
        width: screenWidth,
        height: bottomSheetHeight,
        color: crdColor,
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: screenWidth - 40,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text("Time Period",
                      style: Theme.of(context).textTheme.headline6),
                  PopupMenuButton(
                    initialValue: timeScope,
                    onSelected: (val) {
                      setState(() {
                        timeScope = val.toString();
                        dateStart = _getPreviousDate(dateEnd, timeScope);
                        _analyzeFinanceList();
                      });
                    },
                    itemBuilder: (context) {
                      return financeAnalyzeScope
                          .map((item) => PopupMenuItem(
                              value: item["value"], child: Text(item["label"])))
                          .toList();
                    },
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: fgColor,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Center(
                        child: Text(timeScope == ""
                            ? "- - -"
                            : financeAnalyzeScope.firstWhere(
                                (item) => item["value"] == timeScope)["label"]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: screenWidth,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                    onPressed: _onPreviousPeriod,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  TextButton(
                    onPressed: () {
                      _onSelectDate(context, isDateEnd: false);
                    },
                    child: Text(
                      DateTimeFormat.dateOnly(dateStart),
                    ),
                  ),
                  const Text("From - To"),
                  TextButton(
                    onPressed: () {
                      _onSelectDate(context, isDateEnd: true);
                    },
                    child: Text(
                      DateTimeFormat.dateOnly(dateEnd),
                    ),
                  ),
                  IconButton(
                    onPressed: _onNextPeriod,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    }*/
  }
}
