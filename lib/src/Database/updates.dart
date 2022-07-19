import 'package:nobrainer/src/Database/tables.dart';
import 'package:sqflite/sqflite.dart';

class DbUpdate {
  static Future<void> createTables(Database db) async {
    for (String table in dbTables) {
      await db.execute("CREATE TABLE IF NOT EXISTS $table;");
    }
  }

  static Future<void> updateDbVersion4(Database db) async {
    await createTables(db);
  }
}
