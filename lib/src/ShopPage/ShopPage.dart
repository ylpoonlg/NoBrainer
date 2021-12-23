import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  _ShopPageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Shopping List Here"),
    );
  }
}
