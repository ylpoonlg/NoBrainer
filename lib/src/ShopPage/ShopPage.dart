import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class ShopPage extends StatefulWidget {
  final String uuid;

  ShopPage({required String this.uuid});

  @override
  State<StatefulWidget> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  _ShopPageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Shopping List"),
      ),
      body: const Text("Some shopping items here..."),
    );
  }
}
