import 'package:flutter/material.dart';
import 'package:nobrainer/src/Theme/custom_icons.dart';

class CustomIconSelector extends StatefulWidget {
  final Function(IconData) onSelect;
  final int                columns;

  const CustomIconSelector({
    required this.onSelect,
    this.columns = 4,
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _CustomIconSelectorState();
  }
}

class _CustomIconSelectorState extends State<CustomIconSelector> {
  List<Widget> getIcons() {
    List<Widget> result = [];
    List<IconData> icons = CustomIcons.getIcons();

    for (IconData icon in icons) {
      result.add(InkWell(
        child: Icon(icon),
        onTap: () {
          widget.onSelect(icon);
        },
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      child: GridView.count(
        crossAxisCount: widget.columns,
        children: getIcons(),
      ),
    );
  }
}
