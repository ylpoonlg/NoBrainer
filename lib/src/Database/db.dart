import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nobrainer/src/Database/tables.dart';
import 'package:nobrainer/src/Database/updates.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';

class DbHelper {
  static late  Database database;
  static       String   dbPath    = "";
  static const String   dbName    = "nobrainer.db";
  static const int      dbVersion = 4;

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

  Future<void> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Check for permissions
    bool isPermissionGranted = await checkPermissions();
    if (!isPermissionGranted) return;

    // Create database if not exist
    List<String> paths = await ExternalPath.getExternalStorageDirectories();
    String      dbPath = paths[0] + "/NoBrainer/";
    Directory(dbPath).createSync(recursive: true);
    DbHelper.dbPath    = dbPath;

    debugPrint("==> Opening database at: " + dbPath);

    database = await openDatabase(
      join(dbPath, dbName),
      onCreate: (db, version) async {
        // Check for old database location
        await DbUpdate.updateDbVersion4(db);
        await DbUpdate.createTables(db);
      },
      onUpgrade: (db, oldver, newver) async {
        if (oldver < 4) {
          await DbUpdate.updateDbVersion4(db);
        }
      },
      version: dbVersion,
    );

    await _debug();
  }

  _debug() async {
    Database db = database;
    try {
      /* Useful SQLITE commands
        ALTER TABLE {table} ADD COLUMN {column} {type};
        ALTER TABLE {table} RENAME COLUMN {old_column} TO {new_column};
      */

      //debugPrint("Done running db operation");
    } catch (e) {
      debugPrint("database debug operation error:\n" + e.toString());
    }
  }
}
