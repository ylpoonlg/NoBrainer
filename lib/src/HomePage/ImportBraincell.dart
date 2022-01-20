import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:uuid/uuid.dart';

class ImportBraincell extends StatefulWidget {
  Function callback;
  ImportBraincell({
    Key? key,
    required this.callback,
  }) : super();

  @override
  State<StatefulWidget> createState() => _ImportBraincellState();
}

class _ImportBraincellState extends State<ImportBraincell> {
  late Map<String, dynamic> cell;
  String uuid = "";

  bool validateInput() {
    return true;
  }

  /// Retreive data from cloud
  ///
  /// Returns true if successful, false otherwise.
  bool loadCellData() {
    if (!validateInput()) return false;
    // Test data
    cell = {
      "uuid": "SAMPLECLOUDUUID",
      "name": "Comming Soon!",
      "type": "todolist",
      "imported": true,
      "color": AppTheme.color["magenta"],
    };
    return true;
  }

  void importBraincell() {
    if (loadCellData()) {
      widget.callback(cell);
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content:
              const Text("Failed to import braincell. Please try again later."),
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
          "Import Braincell",
          style: TextStyle(color: Colors.white),
        ),
        actions: [],
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 20),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: TextEditingController(text: uuid),
              onChanged: (text) {},
              decoration: const InputDecoration(
                labelText: "UUID",
                hintText: "Enter the uuid of a braincell",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: TextButton(
              onPressed: importBraincell,
              child: const Text("Import"),
              style: TextButton.styleFrom(
                primary: AppTheme.color["white"],
                backgroundColor: AppTheme.color["accent-primary"],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
