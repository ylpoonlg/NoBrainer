import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TodoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  _TodoPageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Todo List Here"),
    );
  }
}
