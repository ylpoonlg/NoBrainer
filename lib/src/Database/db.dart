import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static dynamic database;

  static const dbName = "nobrainer.db";
  static const int dbVersion = 2;

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
        if (oldver < 2) {
          await db
              .execute("ALTER TABLE braincells ADD COLUMN orderIndex INTEGER;");
          await db.execute("UPDATE braincells SET orderIndex=0;");
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
      //await db.execute("ALTER TABLE braincells ADD COLUMN orderIndex INTEGER;");
      //await db.execute("UPDATE braincells SET orderIndex=0;");

      // await db.execute("DROP TABLE braincells;");
      // await db.execute("DROP TABLE settings;");
      //_createTables(db);
    } catch (e) {}
  }
}
