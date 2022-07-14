import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class BorderButton extends StatelessWidget {
  void Function() onPressed;
  Widget child;
  EdgeInsets? padding;
  BorderButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color fgColor = Theme.of(context).colorScheme.onBackground;

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: fgColor, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(6),
            child: child,
          ),
        ),
      ),
    );
  }
}
