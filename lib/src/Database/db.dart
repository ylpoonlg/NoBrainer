import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';

class DbHelper {
  static dynamic database;

  static const dbName = "nobrainer.db";
  static String dbPath = "";

  /// Current database version, increment by one for major updates
  static const int dbVersion = 4;

  DbHelper();

  static Future<bool> checkPermissions() async {
    PermissionStatus storagePermission = await Permission.storage.request();
    if (!storagePermission.isGranted) return false;

    if (Platform.isAndroid) {
      int sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt ?? -1;
      if (sdk >= 30) {
        PermissionStatus managePermission =
            await Permission.manageExternalStorage.request();
        if (!managePermission.isGranted) return false;
      }
    }

    return true;
  }

  /// Initialize database and set database to Future<Database> if null and permission granted.
  Future initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (database != null) return;

    // Check for permissions
    bool isPermissionGranted = await checkPermissions();
    if (!isPermissionGranted) return;

    List<String> paths = await ExternalPath.getExternalStorageDirectories();
    String dbPath = paths[0] + "/NoBrainer/";
    Directory(dbPath).createSync(recursive: true);
    debugPrint(" ==> Open database at: " + dbPath);
    DbHelper.dbPath = dbPath;

    database = openDatabase(
      join(dbPath, dbName),
      onCreate: (db, version) async {
        _createTables(db);
      },
      onUpgrade: (db, oldver, newver) async {
        // New tables structure
        if (oldver < 4) {
          _createTables(db);
        }
      },
      version: dbVersion,
    );

    await database;
    await _debug();
  }

  void _createTables(db) async {
    for (String table in dbTables) {
      await db.execute("CREATE TABLE IF NOT EXISTS $table;");
    }
  }

  _debug() async {
    final Database db = await database;

    try {
      // db.execute("ALTER TABLE ShopItems ADD COLUMN quantity INTEGER;");
      //db.execute("ALTER TABLE TodoItems RENAME COLUMN notifyid TO notifytime;");

      //debugPrint("Done running db operation");
    } catch (e) {
      debugPrint("database debug operation error:\n" + e.toString());
    }
  }
}
