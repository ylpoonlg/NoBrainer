import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/FinancePage/CategoryList.dart';
import 'package:nobrainer/src/Widgets/CustomIconSelector.dart';
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
    "icon": Icons.brush,
    "icon_string": "custom",
    "color": AppTheme.color["orange"],
  };

  _onCreate() {
    bool catExist = false;
    CategoryListState.categories.forEach((cat) {
      if (cat["cat"] == newCat["cat"]) {
        catExist = true;
      }
    });
    if (!catExist && newCat["cat"] != "") {
      widget.onCreate(newCat);
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Failed to Create New Category"),
            content: const Text(
                "This category already exist.\nTry a different name."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Confirm"),
              )
            ],
          );
        },
      );
    }
  }

  _onSelectIcon(context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select an Icon"),
        content: CustomIconSelector(
          width: screenWidth - 100,
          height: screenHeight - 500,
          onSelect: (iconName) {
            Navigator.of(context).pop();
            setState(() {
              newCat["icon_string"] = iconName;
              newCat["icon"] = AppTheme.icon[iconName];
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  _onSelectColor(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: newCat["color"],
            paletteType: PaletteType.hueWheel,
            onColorChanged: (color) {
              setState(() {
                newCat["color"] = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Select"),
          )
        ],
      ),
    );
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
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

            // Icon Preview
            Container(
              padding: const EdgeInsets.all(20),
              child: Icon(
                newCat["icon"],
                size: 64,
                color: newCat["color"],
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _onSelectIcon(context);
                      },
                      child: Text(
                        "Icon",
                        style: TextStyle(
                          color: AppTheme.color["white"],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _onSelectColor(context);
                      },
                      child: Text(
                        "Color",
                        style: TextStyle(
                          color: AppTheme.color["white"],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
