import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';
import 'package:sqflite/sqflite.dart';

class PayMethods {
  static Future<List<String>> getPayMethods() async {
    Database  db   = DbHelper.database;
    List<Map> rows = await db.query(
      DbTableName.payMethods,
    );
    return rows.map((row) => row["name"].toString()).toList();
  }

  static Future<void> newPayMethod(String payMethod) async {
    Database db = DbHelper.database;
    await db.insert(
      DbTableName.payMethods,
      {
        "name": payMethod,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deletePayMethod(String payMethod) async {
    Database db = DbHelper.database;
    await db.delete(
      DbTableName.payMethods,
      where:     "name = ?",
      whereArgs: [payMethod],
    );
  }
}

class PayMethodsList extends StatefulWidget {
  final String           payMethod;
  final Function(String) onChanged;

  const PayMethodsList({
    required this.payMethod,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PayMethodsListState();
}

class _PayMethodsListState extends State<PayMethodsList> {
  String       payMethod = "";
  List<String> payMethods = [];
  bool         isLoaded   = false;

  _PayMethodsListState() {
    loadPayMethods();
  }

  loadPayMethods() async {
    payMethods = await PayMethods.getPayMethods();
    setState(() {
      isLoaded = true;
    });
  }

  addPayMethod(String methodName) async {
    await PayMethods.newPayMethod(methodName);
    loadPayMethods();
  }

  deletePayMethod(String methodName) async {
    await PayMethods.deletePayMethod(methodName);
    loadPayMethods();
  }

  onNewMethod() {
    String newPayMethodName = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Payment Method"),
        content: TextField(
          controller: TextEditor.getController(newPayMethodName),
          onChanged: (value) {
            newPayMethodName = value;
          },
          decoration: const InputDecoration(
            labelText: "Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              addPayMethod(newPayMethodName);
              Navigator.of(context).pop();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  onDeleteMethod(String methodName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure to delete this payment method?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                deletePayMethod(methodName);
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
          ]),
    );
  }

  List<Widget> buildPayMethodsList() {
    List<Widget> items = [];

    items.add(
      ListTile(
        onTap: () {
          setState(() {
            payMethod = "";
            widget.onChanged(payMethod);
          });
        },
        title: const Text("None", textAlign: TextAlign.center),
        tileColor: payMethod == ""
          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.2)
          : null,
      ),
    );

    for (String method in payMethods) {
      items.add(
        ListTile(
          onTap: () {
            setState(() {
              payMethod = method;
              widget.onChanged(payMethod);
            });
          },
          tileColor: payMethod == method
            ? Colors.grey.withOpacity(0.2)
            : null,
          title: Text(method),
          trailing: IconButton(
            onPressed: () {
              onDeleteMethod(method);
            },
            icon: const Icon(Icons.delete),
          ),
        )
      );
    }

    items.add(ListTile(
      title: TextButton.icon(
        onPressed: onNewMethod,
        icon:  const Icon(Icons.add_card),
        label: const Text("New Payment Method"),
      ),
    ));

    return items;
  }

  @override
  void initState() {
    super.initState();
    payMethod = widget.payMethod;
  }

  @override
  Widget build(context) {
    return isLoaded
      ? Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          child: ListView(
            children: buildPayMethodsList(),
          ),
        )
      : const Center(child: CircularProgressIndicator());
  }
}
