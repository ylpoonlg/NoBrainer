import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static dynamic database;

  static const dbName = "nobrainer.db";

  DbHelper();

  Future initDatabase() async {
    if (database != null) return;

    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) async {
        _createTables(db);
      },
      version: 1,
    );

    await _debug();
  }

  void _createTables(db) async {
    await db.execute(
      '''CREATE TABLE braincells (
        uuid TEXT PRIMARY KEY,
        index INTEGER UNIQUE,
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
      //await db.execute("ALTER TABLE braincells ADD COLUMN orderIndex INTEGER;");
      //await db.execute("UPDATE braincells SET orderIndex=0;");

      // await db.execute("DROP TABLE braincells;");
      // await db.execute("DROP TABLE settings;");
      // _createTables(db);
    } catch (e) {}
  }
}
