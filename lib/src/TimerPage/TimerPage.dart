import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  _TimerPageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Timer Here"),
    );
  }
}
