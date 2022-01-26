import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static dynamic database;

  static const dbName = "nobrainer.db";

  /// Current database version, increment by one for major updates
  static const int dbVersion = 3;

  DbHelper();

  Future initDatabase() async {
    if (database != null) return;

    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) async {
        _createTables(db);
      },
      onUpgrade: (db, oldver, newver) async {
        // Reorder braincells
        if (oldver < 2) {
          await db
              .execute("ALTER TABLE braincells ADD COLUMN orderIndex INTEGER;");
          await db.execute("UPDATE braincells SET orderIndex=0;");
        }
        // Custom Categories
        if (oldver < 3) {
          await db.insert(
            "settings",
            {
              "name": "finance-custom-cat",
              "value": "[]",
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      },
      version: dbVersion,
    );

    await _debug();
  }

  void _createTables(db) async {
    await db.execute(
      '''CREATE TABLE braincells (
        uuid TEXT PRIMARY KEY,
        orderIndex INTEGER,
        props TEXT,
        content TEXT
      );''',
    );
    await db.execute(
      '''CREATE TABLE settings (name TEXT PRIMARY KEY, value TEXT);''',
    );
  }

  _debug() async {
    final Database db = await database;

    try {
      // DB operations

    } catch (e) {
      debugPrint("database debug operation error:\n" + e.toString());
    }
  }
}
