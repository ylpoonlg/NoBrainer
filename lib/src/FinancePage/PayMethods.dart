import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/Widgets/TextEditor.dart';
import 'package:sqflite/sqflite.dart';

class PayMethods {
  static List<String> payMethods = [];

  static getPayMethods() async {
    final Database db = await DbHelper.database;
    dynamic dbMap = await db.query(
      "settings",
      where: "name = ?",
      whereArgs: ["finance-paymethods"],
    );
    if (dbMap.isEmpty) {
      payMethods = [];
    } else {
      payMethods = List<String>.from(json.decode(dbMap[0]["value"]).toList());
    }
  }

  static savePayMethod() async {
    final Database db = await DbHelper.database;
    await db.execute(
      "INSERT OR REPLACE INTO settings (name, value) "
      "VALUES (?, ?)",
      ["finance-paymethods", json.encode(payMethods)],
    );
  }

  static addPayMethod(String methodName) {
    payMethods.add(methodName);
    savePayMethod();
  }

  static deletePayMethod(String methodName) {
    payMethods.removeWhere((item) => item == methodName);
    savePayMethod();
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
  State<StatefulWidget> createState() => _PayMethodsListState(payMethod);
}

class _PayMethodsListState extends State<PayMethodsList> {
  String _payMethod = "";
  bool isLoaded = false;

  _PayMethodsListState(this._payMethod) {
    loadPayMethods();
  }

  loadPayMethods() async {
    await PayMethods.getPayMethods();
    setState(() {
      isLoaded = true;
    });
  }

  addPayMethod(String methodName) async {
    setState(() {
      isLoaded = false;
    });
    await PayMethods.addPayMethod(methodName);
    await loadPayMethods();
  }

  deletePayMethod(String methodName) async {
    await PayMethods.deletePayMethod(methodName);
    await loadPayMethods();
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
                ...PayMethods.payMethods
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
