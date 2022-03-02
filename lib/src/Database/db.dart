import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';

class DbHelper {
  static dynamic database;

  static const dbName = "nobrainer.db";

  /// Current database version, increment by one for major updates
  static const int dbVersion = 3;

  DbHelper();

  /// Returns true if user has granted the app with the provided permission 
  Future<bool> checkPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    if (status.isGranted) {
      debugPrint("Permission granted!");
      return true;
    } else if (await Permission.storage.request().isDenied) {
      debugPrint("Permission denied");
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      debugPrint("Permission permenantly denied");
    }
    return false;
  }

  /// Initialize database and set database to Future<Database> if null and permission granted.
  Future initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (database != null) return;


    /** Experimental - for migrating to external storage for easier backup */
    // Check storage permission
    //bool isPermissionGranted = await checkPermission(Permission.manageExternalStorage);
    //if (!isPermissionGranted) return;
    //Directory("/storage/emulated/0/NoBrainer/").create(recursive: true);
    //String dbPath = "/storage/emulated/0/NoBrainer";

    String dbPath = await getDatabasesPath();
    debugPrint(" ==> Open database at: " + dbPath);

    database = openDatabase(
      join(dbPath, dbName),
      onCreate: (db, version) async {
        _createTables(db);
      },
      onUpgrade: (db, oldver, newver) async {
        // Reorder braincells
        if (oldver < 4) {
        }
      },
      version: dbVersion,
    );

    await database;
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
