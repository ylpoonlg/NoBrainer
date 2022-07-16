import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';
import 'package:sqflite/sqflite.dart';

class PayMethods {
  static Future<List<String>> getPayMethods() async {
    Database  db   = await DbHelper.database;
    List<Map> rows = await db.query(
      DbTableName.payMethods,
    );
    return rows.map((row) => row["name"].toString()).toList();
  }

  static Future<void> newPayMethod(String payMethod) async {
    Database db = await DbHelper.database;
    await db.insert(
      DbTableName.payMethods,
      {
        "name": payMethod,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deletePayMethod(String payMethod) async {
    Database db = await DbHelper.database;
    await db.delete(
      DbTableName.payMethods,
      where:     "name = ?",
      whereArgs: [payMethod],
    );
  }
}

class PayMethodsList extends StatefulWidget {
  final String payMethod;
  final Function(String) onChanged;

  const PayMethodsList({
    Key? key,
    required this.payMethod,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PayMethodsListState();
}

class _PayMethodsListState extends State<PayMethodsList> {
  String       _payMethod = "";
  List<String> payMethods = [];
  bool         isLoaded   = false;

  _PayMethodsListState() {
    loadPayMethods();
  }

  loadPayMethods() async {
    _payMethod = widget.payMethod;
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

  @override
  Widget build(context) {
    return isLoaded
        ? Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView(
              children: [
                ListTile(
                  title: const Text("None"),
                  leading: Radio(
                    value: "",
                    groupValue: _payMethod,
                    onChanged: (value) {
                      setState(() {
                        _payMethod = "";
                        widget.onChanged(_payMethod);
                      });
                    },
                  ),
                ),
                ...payMethods
                    .map(
                      (method) => ListTile(
                        leading: Radio(
                          value: method,
                          groupValue: _payMethod,
                          onChanged: (value) {
                            setState(() {
                              _payMethod = value.toString();
                              widget.onChanged(_payMethod);
                            });
                          },
                        ),
                        title: Text(method),
                        trailing: IconButton(
                          onPressed: () {
                            onDeleteMethod(method);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                    )
                    .toList(),
                ListTile(
                  onTap: onNewMethod,
                  leading: const Icon(Icons.add),
                  title: const Text("New Payment Method"),
                ),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
