import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class NewBraincell extends StatefulWidget {
  bool isEditMode = false;
  Map<String, dynamic>? cell;
  Function callback;

  NewBraincell({
    Key? key,
    this.isEditMode = false,
    this.cell,
    required this.callback,
  }) : super();

  @override
  State<StatefulWidget> createState() => _NewBraincellState();
}

/// Convert type value to a label text
Map<String, String> typeLabel = {
  "todolist": "Todo List",
  "shoplist": "Shopping List",
  "select": "Select a type",
};

class _NewBraincellState extends State<NewBraincell> {
  Map<String, dynamic> cell = {
    "uuid": const Uuid().v1(),
    "name": "My Braincell",
    "type": "select",
    "imported": false,
    "color": AppTheme.color["light-gray"],
  };

  bool validateInput() {
    if (cell["name"] == "") return false;
    if (cell["type"] == "select") return false;
    return true;
  }

  addBraincell(context) {
    if (validateInput()) {
      widget.callback(cell);
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid Settings"),
          content: const Text("Please check your inputs."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK")),
          ],
        ),
      );
    }
  }

  _onSelectColor(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: cell["color"],
            paletteType: PaletteType.hueWheel,
            onColorChanged: (color) {
              setState(() {
                cell["color"] = color;
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
    if (widget.cell != null) {
      cell = widget.cell ?? {};
    }

    final Color foregroundColor =
        AppTheme.getColorBrightness(cell["color"]) < 0.5
            ? AppTheme.color["white"]
            : AppTheme.color["black"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text(
          "New Braincell",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () {
                addBraincell(context);
              },
              child: Text(
                widget.isEditMode ? "Save" : "Add",
                style: TextStyle(color: AppTheme.color["white"]),
              ))
        ],
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: TextEditingController(text: cell["name"]),
              onChanged: (text) {
                cell["name"] = text;
              },
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Enter the name of this braincell",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          !widget.isEditMode
              ? PopupMenuButton(
                  initialValue: cell["type"],
                  onSelected: (value) {
                    setState(() {
                      cell["type"] = value.toString();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Spacer(),
                        const Icon(Icons.list),
                        Text("  " + typeLabel[cell["type"]].toString()),
                        const Spacer(),
                      ],
                    ),
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                          value: "todolist",
                          child: Text(typeLabel["todolist"].toString())),
                      PopupMenuItem<String>(
                          value: "shoplist",
                          child: Text(typeLabel["shoplist"].toString())),
                    ];
                  },
                )
              // Placeholder: Imported Brinacells cannot have their type changed
              : const Text(""),
          SizedBox(
            height: 64,
            child: TextButton(
              onPressed: () {
                _onSelectColor(context);
              },
              child: const Text("Color"),
              style: TextButton.styleFrom(
                primary: foregroundColor,
                backgroundColor: cell["color"],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
