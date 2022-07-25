import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:nobrainer/src/BrainCell/BrainCell.dart';

class NewBraincell extends StatefulWidget {
  final bool      isEditMode;
  final BrainCell cell;
  final Function  callback;

  const NewBraincell({
    this.isEditMode = false,
    required this.cell,
    required this.callback,
    Key? key,
  }) : super(key: key);

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
        return "Shopping List";
      case BrainCellType.moneyPit:
        return "Money Pit";
      default:
        return "Select a Braincell Type";
    }
  }
  String cellTypeInfo(String type) {
    switch (type) {
      case BrainCellType.todoList:
        return "Todo List cell can remind you of important tasks"
          " and also send you notification";
      case BrainCellType.shopList:
        return "Shopping List shows all the items that you have to buy"
          " when you enter a shop";
      case BrainCellType.moneyPit:
        return "Money Pit cell allows you to keep track of your expenses"
          " and analyze them by different spending categories";
      default:
        return "Please choose a valid BrainCell type";
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
    final Color foregroundColor = cell.color.computeLuminance() < 0.5
      ? Colors.white
      : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? "Edit Braincell" : "New Braincell"),
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              addBraincell(context);
            },
            child: Text(widget.isEditMode ? "Save" : "Add"),
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(80, 64)),
            ),
          ),
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
            ? Text(
              "\nBrainCell Type",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            )
            : Container(),

          !widget.isEditMode
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical:   15,
                ),
                child: GridView.count(
                  primary:          false,
                  crossAxisCount:   2,
                  childAspectRatio: 3,
                  shrinkWrap:       true,
                  children: [
                    BrainCellType.todoList,
                    BrainCellType.shopList,
                    BrainCellType.moneyPit,
                  ].map((String type) => Card(
                    color: cell.type == type
                      ? Theme.of(context).colorScheme
                        .surface.withOpacity(0.10)
                      : null,
                    elevation: 1,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          cell.type = type;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cellTypeText(type),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title:   Text(cellTypeText(type)),
                                    content: Text(cellTypeInfo(type)),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("OK"),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.info_outline),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                )
              )
            : Container(),

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
