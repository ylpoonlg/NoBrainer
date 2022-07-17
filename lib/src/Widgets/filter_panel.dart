import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final bool   isShown;
  final Widget child;
  final double height;

  const FilterPanel({
    required this.isShown,
    required this.child,
    this.height = 400,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(
        begin: 0, end: isShown ? height : 0,
      ),
      duration: const Duration(milliseconds: 200),
      builder:  (context, double value, child) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: value,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 20,
            )],
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}
