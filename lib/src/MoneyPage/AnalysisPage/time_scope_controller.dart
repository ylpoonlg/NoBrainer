import 'package:flutter/material.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/Widgets/DateTimeFormat.dart';

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
        return "Custom";
    }
  }


  late DateTime dateFrom;
  late DateTime dateTo;
  late String   scope;

  TimeScope({DateTime? from, DateTime? to, this.scope = TimeScope.unset}) {
    DateTime nowTime = DateTime.now();
    DateTime nowDate = DateTime(
      nowTime.year,
      nowTime.month,
      nowTime.day,
    );
    dateFrom = from ?? nowDate;
    dateTo   = to   ?? nowDate;
    setScope(scope: scope);
  }

  void setScope({
    required String scope,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    this.scope = scope;
    if (dateFrom == null && dateTo == null) dateTo = this.dateTo;

    if (dateTo == null && dateFrom != null) {
      nextScope(dateTo: dateFrom.subtract(const Duration(days: 1)));
    } else if (dateTo != null) {
      previousScope(dateFrom: dateTo.add(const Duration(days: 1)));
    }
  }

  void nextScope({DateTime? dateTo}) {
    dateTo ??= this.dateTo;
    dateFrom = dateTo.add(const Duration(days: 1));
    switch (scope) {
      case TimeScope.week:
        this.dateTo = dateFrom.add(const Duration(days: 6));
        break;
      case TimeScope.month:
        this.dateTo = DateTime(
          dateTo.year,
          dateTo.month + 1,
          dateTo.day,
        );
        break;
      case TimeScope.year:
        this.dateTo = DateTime(
          dateTo.year + 1,
          dateTo.month,
          dateTo.day,
        );
        break;
    }
  }

  void previousScope({DateTime? dateFrom}) {
    dateFrom ??= this.dateFrom;
    dateTo = dateFrom.subtract(const Duration(days: 1));
    switch (scope) {
      case TimeScope.week:
        this.dateFrom = dateTo.subtract(const Duration(days: 6));
        break;
      case TimeScope.month:
        this.dateFrom = DateTime(
          dateFrom.year,
          dateFrom.month - 1,
          dateFrom.day,
        );
        break;
      case TimeScope.year:
        this.dateFrom = DateTime(
          dateFrom.year - 1,
          dateFrom.month,
          dateFrom.day,
        );
        break;
    }
  }
}


class TimeScopeController extends StatefulWidget {
  final TimeScope           scope;
  final Function(TimeScope) onChange;
  final double              height;

  const TimeScopeController({
    required this.scope,
    required this.onChange,
    required this.height,
    Key? key,
  }) : super(key: key);

  @override
    State<StatefulWidget> createState() => _TimeScopeControllerState();
}

class _TimeScopeControllerState extends State<TimeScopeController> {
  late TimeScope scope;

  void _onNextScope() {
    setState(() {
      scope.nextScope();
      widget.onChange(scope);
    });
  }

  void _onPreviousScope() {
    setState(() {
      scope.previousScope();
      widget.onChange(scope);
    });
  }

  void _onSetScope(String value) {
    setState(() {
      scope.setScope(scope: value);
      widget.onChange(scope);
    });
  }

  void _onSelectDate({bool isDateTo = true}) {
    showDialog(
      context: context,
      builder: (context) => DatePickerDialog(
        initialDate: isDateTo ? scope.dateTo : scope.dateFrom,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialCalendarMode: DatePickerMode.day,
      ),
    ).then((date) {
      setState(() {
        if (date != null) {
          if (isDateTo) {
            scope.dateTo = DateTime(
              date.year,
              date.month,
              date.day,
            );
          } else {
            scope.dateFrom = DateTime(
              date.year,
              date.month,
              date.day,
            );
          }
        }
        scope.scope = TimeScope.unset;
        widget.onChange(scope);
      });
    });
  }
  
  @override
  void initState() {
    super.initState();
    scope = widget.scope;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth  = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width:  screenWidth,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        boxShadow: const [
          BoxShadow(
            color:        Colors.black87,
            blurRadius:   20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceAround,
              direction: Axis.horizontal,
              children: const [
                SizedBox(
                  width: 80,
                  child: Text("From", textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 80,
                  child: Text("To", textAlign: TextAlign.center),
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              direction: Axis.horizontal,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _onSelectDate(isDateTo: false);
                  },
                  child: Text(DateTimeFormat.dateOnly(scope.dateFrom)),
                ),
                OutlinedButton(
                  onPressed: () {
                    _onSelectDate(isDateTo: true);
                  },
                  child: Text(DateTimeFormat.dateOnly(scope.dateTo)),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Wrap(
              alignment: WrapAlignment.spaceAround,
              direction: Axis.horizontal,
              children: [
                IconButton(
                  onPressed: scope.scope == TimeScope.unset
                    ? null : _onPreviousScope,
                  icon: const Icon(Icons.navigate_before),
                ),

                DropdownButton<String>(
                  value: scope.scope,
                  items: [
                    TimeScope.week,
                    TimeScope.month,
                    TimeScope.year,
                    TimeScope.unset,
                  ].map((scope) => DropdownMenuItem<String>(
                    child: Text(TimeScope.getLabel(scope)),
                    value: scope,
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _onSetScope(value);
                    }
                  },
                ),
                IconButton(
                  onPressed: scope.scope == TimeScope.unset
                    ? null : _onNextScope,
                  icon: const Icon(Icons.navigate_next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
