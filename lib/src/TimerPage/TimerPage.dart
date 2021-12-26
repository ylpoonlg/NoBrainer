import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class TimerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  _TimerPageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Timer"),
      ),
      body: const Text("Some timer threads here..."),
    );
  }
}
