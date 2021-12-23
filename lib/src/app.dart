import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/HomePage/HomePage.dart';

class NoBrainerApp extends StatelessWidget {
  const NoBrainerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'No Brainer',
      theme: AppTheme().theme(),
      home: HomePage(),
    );
  }
}
