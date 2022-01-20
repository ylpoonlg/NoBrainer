import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/db.dart';
import 'package:nobrainer/src/app.dart';

main() async {
  await DbHelper().initDatabase(); // Init database instance
  await DbHelper.database;
  runApp(NoBrainerApp());
}
