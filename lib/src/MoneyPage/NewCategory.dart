import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:nobrainer/src/MoneyPage/MoneyCategory.dart';
import 'package:nobrainer/src/Theme/AppTheme.dart';
import 'package:nobrainer/src/Widgets/custom_icons_selector.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';

class NewCategory extends StatefulWidget {
  final Function(MoneyCategory) onCreate;

  const NewCategory({required this.onCreate, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  MoneyCategory newCat =
    MoneyCategory(name: "", icon: null, color: Colors.grey);

  _onCreate() async {
    // Validate
    bool catExist = false;
    List<MoneyCategory> categories = await MoneyCategory.getCategories();
    for (MoneyCategory category in categories) {
      if (category.name == newCat.name) {
        catExist = true;
        break;
      }
    }

    if (!catExist && newCat.name != "") {
      widget.onCreate(newCat);
      Navigator.of(context).pop();
    } else {
      String alertMessage;
      if (newCat.name == "") {
        alertMessage = "Invalid category name";
      } else {
        alertMessage = "Category already exist";
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Failed to Create New Category"),
            content: Text(alertMessage),
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
        content: SizedBox(
          width: screenWidth - 100,
          height: screenHeight - 500,
          child: CustomIconSelector(
            onSelect: (icon) {
              setState(() {
                newCat.icon = icon;
              });
              Navigator.of(context).pop();
            },
          ),
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
            pickerColor: newCat.color,
            paletteType: PaletteType.hueWheel,
            onColorChanged: (color) {
              setState(() {
                newCat.color = color;
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
        title: const Text("Create New Category"),
        actions: [
          TextButton(
            onPressed: _onCreate,
            child: const Text("Create"),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            const SizedBox(height: 20),

            ListTile(
              title: Card(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Icon(
                          newCat.icon,
                          size: 64,
                          color: newCat.color,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: newCat.color,
                          ),
                          borderRadius:
                            const BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              _onSelectIcon(context);
                            },
                            child: const Text("Icon"),
                          ),
                          TextButton(
                            onPressed: () {
                              _onSelectColor(context);
                            },
                            child: const Text("Color"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ListTile(
              contentPadding: listTilePadding,
              title: TextField(
                controller: TextEditor.getController(newCat.name),
                onChanged: (text) {
                  newCat.name = text;
                },
                decoration: const InputDecoration(
                  labelText: "Category Name",
                  hintText: "e.g. Transportation, Bills",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
