import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';

class NewCategory extends StatefulWidget {
  Function(Map) onCreate;

  NewCategory(this.onCreate) : super();

  @override
  State<StatefulWidget> createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  Map<String, dynamic> newCat = {
    "cat": "Custom Category",
    "icon": Icons.alarm,
    "icon_string": "alarm",
    "color": AppTheme.color["cyan"],
  };

  _onCreate() {
    widget.onCreate(newCat);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsetsGeometry listTilePadding = EdgeInsets.only(
      top: 16,
      left: 16,
      right: 16,
      bottom: 0,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Create New Category"),
        actions: [
          TextButton(
            onPressed: _onCreate,
            child: Text(
              "Create",
              style: TextStyle(color: AppTheme.color["white"]),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            contentPadding: listTilePadding,
            title: TextField(
              controller: TextEditor.getController(newCat["cat"]),
              onChanged: (text) {
                newCat["cat"] = text;
              },
              decoration: const InputDecoration(
                labelText: "Title",
                hintText: "Enter the title of the task",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
