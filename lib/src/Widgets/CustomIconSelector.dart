import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class CustomIconSelector extends StatefulWidget {
  Function onSelect;
  double width, height;
  int columns;

  CustomIconSelector({
    required this.onSelect,
    required this.width,
    required this.height,
    this.columns = 4,
  });
  @override
  State<StatefulWidget> createState() {
    return _CustomIconSelectorState();
  }
}

class _CustomIconSelectorState extends State<CustomIconSelector> {
  List<Widget> getIcons() {
    List<Widget> result = [];
    List iconNames = AppTheme.icon.keys.toList();

    for (int i = 0; i < iconNames.length; i++) {
      result.add(InkWell(
        child: Icon(AppTheme.icon[iconNames[i].toString()]),
        onTap: () {
          widget.onSelect(iconNames[i].toString());
        },
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GridView.count(
        crossAxisCount: widget.columns,
        children: getIcons(),
      ),
    );
  }
}
