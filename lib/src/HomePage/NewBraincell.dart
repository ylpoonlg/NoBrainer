import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/res/values/DisplayValues.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';
import 'package:uuid/uuid.dart';

class NewBraincell extends StatefulWidget {
  bool isEditMode = false;
  BrainCell cell;
  Function callback;

  NewBraincell({
    Key? key,
    this.isEditMode = false,
    required this.cell,
    required this.callback,
  }) : super();

  @override
  State<StatefulWidget> createState() => _NewBraincellState();
}

class _NewBraincellState extends State<NewBraincell> {
  late BrainCell cell = widget.cell;

  bool validateInput() {
    if (cell.title == "") return false;
    if (cell.type == BrainCellType.none) return false;
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


  String cellTypeText(String type) {
    switch (type) {
      case BrainCellType.todoList:
        return "Todo List";
      case BrainCellType.shopList:
        return "Shop List";
      case BrainCellType.moneyPit:
        return "Money Pit";
      default:
        return "Select a Braincell Type";
    }
  }

  _onSelectColor(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: cell.color,
            paletteType: PaletteType.hueWheel,
            onColorChanged: (color) {
              setState(() {
                cell.color = color;
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
    final Color foregroundColor = cell.color.computeLuminance() < 0.5 ?
      AppTheme.color["white"] :
      AppTheme.color["black"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Braincell"),
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
              controller: TextEditingController(text: cell.title),
              onChanged: (text) {
                cell.title = text;
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
                  initialValue: cell.type,
                  onSelected: (value) {
                    setState(() {
                      cell.type = value.toString();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Spacer(),
                        const Icon(Icons.list),
                        Text("  "+cellTypeText(cell.type)),
                        const Spacer(),
                      ],
                    ),
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      BrainCellType.todoList,
                      BrainCellType.shopList,
                      BrainCellType.moneyPit,
                    ].map((type) => PopupMenuItem<String>(
                      value: type,
                      child: Text(cellTypeText(type)),
                    )).toList();
                  },
                )
              // Placeholder: Imported Brinacells cannot have their type changed
              : const Text(""),
          Container(
            height: 72,
            padding: const EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {
                _onSelectColor(context);
              },
              child: const Text("Color"),
              style: TextButton.styleFrom(
                foregroundColor: foregroundColor,
                backgroundColor: cell.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
