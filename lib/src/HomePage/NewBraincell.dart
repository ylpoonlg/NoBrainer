import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:uuid/uuid.dart';

class NewBraincell extends StatefulWidget {
  bool isEditMode = false;
  Function callback;
  NewBraincell({
    Key? key,
    this.isEditMode = false,
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
    "color": AppTheme.color["cyan"],
  };

  bool validateInput() {
    if (cell["name"] == "") return false;
    if (cell["type"] == "select") return false;
    return true;
  }

  void addBraincell() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text(
          "New Braincell",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: addBraincell,
              child: Text(
                "Add",
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
                        Text(" Type: " + typeLabel[cell["type"]].toString()),
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
        ],
      ),
    );
  }
}
