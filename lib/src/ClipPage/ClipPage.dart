import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class ClipPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ClipPageState();
}

class _ClipPageState extends State<ClipPage> {
  _ClipPageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Clipboard"),
      ),
      body: const Text("Some clipped items here..."),
    );
  }
}
