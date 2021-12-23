import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ClipPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ClipPageState();
}

class _ClipPageState extends State<ClipPage> {
  _ClipPageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Clipboard Here"),
    );
  }
}
