import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String DB_NAME = "nobrainer.db";

class DbHelper {
  static dynamic database;

  static const dbName = "nobrainer.db";

  DbHelper() {
    initDatabase();
  }

  void initDatabase() async {
    //print("DB PATH: " + await getDatabasesPath());
    if (database != null) return;

    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, version) async {
        _createTables(db);
      },
      version: 1,
    );

    _debug();
  }

  void _createTables(db) async {
    await db.execute(
      '''CREATE TABLE braincells (
        uuid TEXT PRIMARY KEY,
        type TEXT,
        content TEXT
      );''',
    );
    await db.execute(
      '''CREATE TABLE settings (name TEXT PRIMARY KEY, value TEXT);''',
    );
  }

  void _debug() async {
    final Database db = await database;

    //db.execute("ALTER TABLE braincells RENAME COLUMN type TO props;");
    //_createTables(db);
  }
}
